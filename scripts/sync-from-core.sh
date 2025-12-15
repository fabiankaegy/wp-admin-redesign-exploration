#!/bin/bash
#
# Sync forked files from WordPress core using git merge
#
# This script performs a three-way merge to pull upstream changes from WordPress
# core into the forked stylesheets. It uses git merge-file to handle conflicts
# the same way git would during a normal merge.
#
# Usage: npm run sync:update
#        or: bash scripts/sync-from-core.sh
#
# Options:
#   --dry-run    Show what would be updated without making changes
#   --force      Overwrite local changes (use with caution)
#

set -e

# Parse arguments first (before sourcing env-config which may prompt)
DRY_RUN=false
FORCE=false
for arg in "$@"; do
    case $arg in
        --dry-run)
            DRY_RUN=true
            ;;
        --force)
            FORCE=true
            ;;
    esac
done

# Get script directory and plugin root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
MAPPING_FILE="$PLUGIN_DIR/file-mapping.json"

# Load environment configuration (will prompt if not set)
source "$SCRIPT_DIR/lib/env-config.sh"

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is required but not installed.${NC}"
    echo "Install with: brew install jq"
    exit 1
fi

# Check if mapping file exists
if [ ! -f "$MAPPING_FILE" ]; then
    echo -e "${RED}Error: file-mapping.json not found at $MAPPING_FILE${NC}"
    exit 1
fi

# Read last sync commit from mapping file
LAST_SYNC=$(jq -r '.lastSyncCommit' "$MAPPING_FILE")

# Check if core repo exists
if [ ! -d "$CORE_PATH" ]; then
    echo -e "${RED}Error: WordPress core repository not found at $CORE_PATH${NC}"
    echo "Please check your .env configuration (CORE_REPO_PATH)."
    exit 1
fi

# Check if last sync commit is set
if [ "$LAST_SYNC" == "null" ] || [ -z "$LAST_SYNC" ]; then
    echo -e "${RED}Error: No lastSyncCommit found in file-mapping.json${NC}"
    echo "Please run 'npm run sync:init' first to initialize the fork."
    exit 1
fi

echo -e "${GREEN}Syncing forked stylesheets from WordPress core...${NC}"
if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}(dry-run mode - no changes will be made)${NC}"
fi
echo ""
echo "Core repository: $CORE_PATH"
echo "Core branch: $CORE_BRANCH"
echo "Last sync commit: $LAST_SYNC"
echo ""

# Get current commit SHA from core
cd "$CORE_PATH"
CURRENT_COMMIT=$(git rev-parse HEAD)

if [ "$LAST_SYNC" == "$CURRENT_COMMIT" ]; then
    echo -e "${GREEN}Already up to date!${NC}"
    exit 0
fi

echo "Current core commit: $CURRENT_COMMIT"
echo ""

# Check if there are changes in tracked files
echo "Checking for changes since last sync..."
echo ""

# Create temp directory for base versions
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Return to plugin directory
cd "$PLUGIN_DIR"

# Counters
UPDATED=0
CONFLICTS=0
UNCHANGED=0
SKIPPED=0
ADDED=0
DELETED=0

# Define tracked directories (relative to core source dir)
TRACKED_DIRS=(
    "src/wp-admin/css"
    "src/wp-includes/css"
)

# Function to get handle from path
get_handle_from_path() {
    local path="$1"
    local filename=$(basename "$path" .css)
    filename=$(basename "$filename" .scss)
    # Remove -rtl suffix
    filename="${filename%-rtl}"
    echo "$filename"
}

# Function to get plugin path from core path
core_to_plugin_path() {
    local core_path="$1"
    # Remove 'src/' prefix and add 'core-styles/' prefix
    echo "core-styles/${core_path#src/}"
}

echo -e "${BLUE}=== Checking for new files in core ===${NC}"
echo ""

# Check for new files in core that aren't in our mapping
cd "$CORE_PATH"
for dir in "${TRACKED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        # Find all CSS and SCSS files
        find "$dir" -type f \( -name "*.css" -o -name "*.scss" \) | while read -r core_file; do
            # Check if this file is in our mapping
            if ! jq -e --arg path "$core_file" '.files[$path]' "$MAPPING_FILE" > /dev/null 2>&1; then
                # Check if file was added after last sync
                FILE_ADDED=$(git log --oneline "$LAST_SYNC".."$CURRENT_COMMIT" --diff-filter=A -- "$core_file" 2>/dev/null | head -1)
                
                if [ -n "$FILE_ADDED" ]; then
                    plugin_path=$(core_to_plugin_path "$core_file")
                    handle=$(get_handle_from_path "$core_file")
                    
                    echo -e "${GREEN}NEW${NC}: $core_file"
                    
                    if [ "$DRY_RUN" = false ]; then
                        # Create directory if needed
                        mkdir -p "$PLUGIN_DIR/$(dirname "$plugin_path")"
                        
                        # Copy the file
                        cp "$CORE_PATH/$core_file" "$PLUGIN_DIR/$plugin_path"
                        
                        # Add to mapping
                        cd "$PLUGIN_DIR"
                        TEMP_MAPPING=$(mktemp)
                        jq --arg core "$core_file" \
                           --arg plugin "$plugin_path" \
                           --arg handle "$handle" \
                           '.files[$core] = {"plugin": $plugin, "handle": $handle}' \
                           "$MAPPING_FILE" > "$TEMP_MAPPING"
                        mv "$TEMP_MAPPING" "$MAPPING_FILE"
                        cd "$CORE_PATH"
                        
                        echo "  Added to plugin and mapping"
                    fi
                    ((ADDED++)) || true
                fi
            fi
        done
    fi
done

echo ""
echo -e "${BLUE}=== Checking for deleted files in core ===${NC}"
echo ""

cd "$PLUGIN_DIR"

# Check for files in our mapping that were deleted in core
jq -r '.files | keys[]' "$MAPPING_FILE" | while read -r core_path; do
    plugin_path=$(jq -r --arg path "$core_path" '.files[$path].plugin' "$MAPPING_FILE")
    
    # Check if file was deleted in core after last sync
    cd "$CORE_PATH"
    FILE_DELETED=$(git log --oneline "$LAST_SYNC".."$CURRENT_COMMIT" --diff-filter=D -- "$core_path" 2>/dev/null | head -1)
    
    if [ -n "$FILE_DELETED" ]; then
        echo -e "${RED}DELETED${NC}: $core_path"
        
        if [ "$DRY_RUN" = false ]; then
            # Remove from plugin
            if [ -f "$PLUGIN_DIR/$plugin_path" ]; then
                rm "$PLUGIN_DIR/$plugin_path"
                echo "  Removed from plugin"
            fi
            
            # Remove from mapping
            cd "$PLUGIN_DIR"
            TEMP_MAPPING=$(mktemp)
            jq --arg path "$core_path" 'del(.files[$path])' "$MAPPING_FILE" > "$TEMP_MAPPING"
            mv "$TEMP_MAPPING" "$MAPPING_FILE"
        fi
        ((DELETED++)) || true
    fi
    cd "$PLUGIN_DIR"
done

echo ""
echo -e "${BLUE}=== Processing modified files ===${NC}"
echo ""

# Process each file in mapping for updates
jq -r '.files | to_entries[] | "\(.key)|\(.value.plugin)"' "$MAPPING_FILE" | while IFS='|' read -r core_path plugin_path; do
    plugin_file="$PLUGIN_DIR/$plugin_path"
    
    # Skip if plugin file doesn't exist (not yet forked)
    if [ ! -f "$plugin_file" ]; then
        echo -e "${YELLOW}SKIP${NC}: $plugin_path (not forked yet)"
        ((SKIPPED++)) || true
        continue
    fi
    
    # Check if file changed in core since last sync
    cd "$CORE_PATH"
    
    # Get diff stat for this file
    CHANGES=$(git diff --name-only "$LAST_SYNC".."$CURRENT_COMMIT" -- "$core_path" 2>/dev/null || echo "")
    
    if [ -z "$CHANGES" ]; then
        # No changes in core
        ((UNCHANGED++)) || true
        continue
    fi
    
    # Check if file still exists in core (not deleted)
    if [ ! -f "$CORE_PATH/$core_path" ]; then
        continue  # Already handled in deleted files section
    fi
    
    echo -e "${BLUE}Processing${NC}: $core_path"
    
    # Extract base version (at last sync point)
    BASE_FILE="$TEMP_DIR/base_$(basename "$core_path")"
    git show "$LAST_SYNC:$core_path" > "$BASE_FILE" 2>/dev/null || {
        echo -e "  ${YELLOW}SKIP${NC}: Could not get base version"
        ((SKIPPED++)) || true
        continue
    }
    
    # Extract current core version
    CORE_FILE="$TEMP_DIR/core_$(basename "$core_path")"
    git show "$CURRENT_COMMIT:$core_path" > "$CORE_FILE" 2>/dev/null || {
        echo -e "  ${YELLOW}SKIP${NC}: Could not get current core version"
        ((SKIPPED++)) || true
        continue
    }
    
    cd "$PLUGIN_DIR"
    
    if [ "$DRY_RUN" = true ]; then
        # Just show diff
        echo -e "  ${GREEN}Would update${NC} (changes in core)"
        ((UPDATED++)) || true
        continue
    fi
    
    if [ "$FORCE" = true ]; then
        # Force overwrite with core version
        cp "$CORE_FILE" "$plugin_file"
        echo -e "  ${GREEN}FORCE${NC}: Overwritten with core version"
        ((UPDATED++)) || true
        continue
    fi
    
    # Perform three-way merge
    # git merge-file modifies the first file in place
    # Returns 0 on clean merge, >0 on conflicts
    cp "$plugin_file" "$TEMP_DIR/plugin_backup"
    
    if git merge-file -L "plugin" -L "base" -L "core" "$plugin_file" "$BASE_FILE" "$CORE_FILE"; then
        echo -e "  ${GREEN}MERGED${NC}: Clean merge"
        ((UPDATED++)) || true
    else
        echo -e "  ${RED}CONFLICT${NC}: Manual resolution required"
        ((CONFLICTS++)) || true
    fi
done

cd "$PLUGIN_DIR"

echo ""
echo "Sync summary:"
echo "  New files added: $ADDED"
echo "  Files deleted: $DELETED"
echo "  Updated: $UPDATED"
echo "  Conflicts: $CONFLICTS"
echo "  Unchanged: $UNCHANGED"
echo "  Skipped: $SKIPPED"
echo ""

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}Dry run complete. No changes were made.${NC}"
    exit 0
fi

if [ "$CONFLICTS" -gt 0 ]; then
    echo -e "${RED}Warning: $CONFLICTS file(s) have merge conflicts.${NC}"
    echo "Please resolve conflicts manually (look for <<<<<<< markers)."
    echo ""
    echo "After resolving conflicts, the lastSyncCommit will NOT be updated."
    echo "Run sync again after resolving to update the commit marker."
    exit 1
fi

# Update lastSyncCommit if no conflicts
if [ "$UPDATED" -gt 0 ] || [ "$UNCHANGED" -gt 0 ] || [ "$ADDED" -gt 0 ] || [ "$DELETED" -gt 0 ]; then
    TEMP_FILE=$(mktemp)
    jq --arg commit "$CURRENT_COMMIT" '.lastSyncCommit = $commit' "$MAPPING_FILE" > "$TEMP_FILE"
    mv "$TEMP_FILE" "$MAPPING_FILE"
    echo -e "${GREEN}Updated lastSyncCommit to: $CURRENT_COMMIT${NC}"
fi

echo ""
echo -e "${GREEN}Sync complete!${NC}"
