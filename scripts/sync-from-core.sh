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

# Process each file in mapping
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
if [ "$UPDATED" -gt 0 ] || [ "$UNCHANGED" -gt 0 ]; then
    TEMP_FILE=$(mktemp)
    jq --arg commit "$CURRENT_COMMIT" '.lastSyncCommit = $commit' "$MAPPING_FILE" > "$TEMP_FILE"
    mv "$TEMP_FILE" "$MAPPING_FILE"
    echo -e "${GREEN}Updated lastSyncCommit to: $CURRENT_COMMIT${NC}"
fi

echo ""
echo -e "${GREEN}Sync complete!${NC}"

