#!/bin/bash
#
# Sync forked stylesheets back to WordPress core
#
# This script copies modified files from the plugin's core-styles directory
# back to WordPress core. Use this when you're ready to propose your CSS
# changes for inclusion in core.
#
# Usage: npm run sync:to-core
#        or: bash scripts/sync-to-core.sh
#
# Options:
#   --dry-run       Show what would be copied without making changes
#   --diff          Show diff of changes that would be applied
#   --branch NAME   Create a new git branch in core before copying
#   --changed-only  Only sync files that differ from core
#   --include-new   Also sync new files not yet in core
#   --include-deleted  Also delete files removed from plugin
#

set -e

# Parse arguments first (before sourcing env-config which may prompt)
DRY_RUN=false
SHOW_DIFF=false
BRANCH_NAME=""
CHANGED_ONLY=false
INCLUDE_NEW=false
INCLUDE_DELETED=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --diff)
            SHOW_DIFF=true
            shift
            ;;
        --branch)
            BRANCH_NAME="$2"
            shift 2
            ;;
        --branch=*)
            BRANCH_NAME="${1#*=}"
            shift
            ;;
        --changed-only)
            CHANGED_ONLY=true
            shift
            ;;
        --include-new)
            INCLUDE_NEW=true
            shift
            ;;
        --include-deleted)
            INCLUDE_DELETED=true
            shift
            ;;
        *)
            shift
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

# Check if core repo exists
if [ ! -d "$CORE_PATH" ]; then
    echo -e "${RED}Error: WordPress core repository not found at $CORE_PATH${NC}"
    echo "Please check your .env configuration (CORE_REPO_PATH)."
    exit 1
fi

echo -e "${GREEN}Syncing forked stylesheets back to WordPress core...${NC}"
if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}(dry-run mode - no changes will be made)${NC}"
fi
if [ "$SHOW_DIFF" = true ]; then
    echo -e "${BLUE}(showing diffs)${NC}"
fi
echo ""
echo "Plugin directory: $PLUGIN_DIR"
echo "Core repository: $CORE_PATH"
echo ""

# Create branch in core if requested
if [ -n "$BRANCH_NAME" ] && [ "$DRY_RUN" = false ]; then
    cd "$CORE_PATH"
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    
    # Check if branch already exists
    if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
        echo -e "${YELLOW}Branch '$BRANCH_NAME' already exists. Switching to it...${NC}"
        git checkout "$BRANCH_NAME"
    else
        echo -e "${GREEN}Creating new branch '$BRANCH_NAME'...${NC}"
        git checkout -b "$BRANCH_NAME"
    fi
    echo ""
fi

cd "$PLUGIN_DIR"

# Counters
COPIED=0
SKIPPED=0
UNCHANGED=0
NEW_FILES=0
DELETED_FILES=0

# Function to get core path from plugin path
plugin_to_core_path() {
    local plugin_path="$1"
    # Remove 'core-styles/' prefix and add 'src/' prefix
    echo "src/${plugin_path#core-styles/}"
}

# Function to get handle from path
get_handle_from_path() {
    local path="$1"
    local filename=$(basename "$path" .css)
    filename=$(basename "$filename" .scss)
    # Remove -rtl suffix
    filename="${filename%-rtl}"
    echo "$filename"
}

# Process mapped files
echo -e "${BLUE}=== Processing mapped files ===${NC}"
echo ""

jq -r '.files | to_entries[] | "\(.key)|\(.value.plugin)"' "$MAPPING_FILE" | while IFS='|' read -r core_path plugin_path; do
    plugin_file="$PLUGIN_DIR/$plugin_path"
    core_file="$CORE_PATH/$core_path"
    
    # Check if plugin file was deleted
    if [ ! -f "$plugin_file" ]; then
        if [ "$INCLUDE_DELETED" = true ]; then
            if [ -f "$core_file" ]; then
                echo -e "${RED}DELETE${NC}: $core_path (removed from plugin)"
                
                if [ "$DRY_RUN" = false ]; then
                    rm "$core_file"
                    echo "  Deleted from core"
                fi
                ((DELETED_FILES++)) || true
            fi
        else
            echo -e "${YELLOW}SKIP${NC}: $plugin_path (file removed from plugin, use --include-deleted to delete from core)"
        fi
        continue
    fi
    
    # Check if files differ
    if [ -f "$core_file" ]; then
        if diff -q "$plugin_file" "$core_file" > /dev/null 2>&1; then
            if [ "$CHANGED_ONLY" = true ]; then
                ((UNCHANGED++)) || true
                continue
            fi
            echo -e "${BLUE}UNCHANGED${NC}: $plugin_path"
            ((UNCHANGED++)) || true
            continue
        fi
    else
        # File doesn't exist in core - this is a new file
        if [ "$INCLUDE_NEW" = false ]; then
            echo -e "${YELLOW}SKIP${NC}: $plugin_path (new file, use --include-new to add to core)"
            continue
        fi
    fi
    
    # Show diff if requested
    if [ "$SHOW_DIFF" = true ]; then
        echo -e "${BLUE}=== Diff for $core_path ===${NC}"
        if [ -f "$core_file" ]; then
            diff --color=always -u "$core_file" "$plugin_file" || true
        else
            echo "(new file)"
            head -20 "$plugin_file"
            echo "..."
        fi
        echo ""
    fi
    
    if [ "$DRY_RUN" = true ]; then
        if [ -f "$core_file" ]; then
            echo -e "${GREEN}Would copy${NC}: $plugin_path -> $core_path"
        else
            echo -e "${GREEN}Would add${NC}: $plugin_path -> $core_path (new file)"
        fi
        ((COPIED++)) || true
        continue
    fi
    
    # Create destination directory if needed
    core_dir=$(dirname "$core_file")
    mkdir -p "$core_dir"
    
    # Copy file
    if cp "$plugin_file" "$core_file"; then
        if [ ! -f "$core_file" ]; then
            echo -e "${GREEN}ADD${NC}: $plugin_path -> $core_path"
            ((NEW_FILES++)) || true
        else
            echo -e "${GREEN}COPY${NC}: $plugin_path -> $core_path"
            ((COPIED++)) || true
        fi
    else
        echo -e "${RED}FAIL${NC}: $plugin_path"
    fi
done

# Check for new files in plugin not in mapping
if [ "$INCLUDE_NEW" = true ]; then
    echo ""
    echo -e "${BLUE}=== Checking for new files in plugin ===${NC}"
    echo ""
    
    # Find all CSS/SCSS files in core-styles that aren't in mapping
    find "$PLUGIN_DIR/core-styles" -type f \( -name "*.css" -o -name "*.scss" \) | while read -r plugin_file; do
        # Get relative path
        plugin_path="${plugin_file#$PLUGIN_DIR/}"
        core_path=$(plugin_to_core_path "$plugin_path")
        
        # Check if in mapping
        if ! jq -e --arg path "$core_path" '.files[$path]' "$MAPPING_FILE" > /dev/null 2>&1; then
            core_file="$CORE_PATH/$core_path"
            handle=$(get_handle_from_path "$plugin_path")
            
            echo -e "${GREEN}NEW${NC}: $plugin_path -> $core_path"
            
            if [ "$DRY_RUN" = false ]; then
                # Create directory if needed
                mkdir -p "$(dirname "$core_file")"
                
                # Copy file
                cp "$plugin_file" "$core_file"
                
                # Add to mapping
                TEMP_MAPPING=$(mktemp)
                jq --arg core "$core_path" \
                   --arg plugin "$plugin_path" \
                   --arg handle "$handle" \
                   '.files[$core] = {"plugin": $plugin, "handle": $handle}' \
                   "$MAPPING_FILE" > "$TEMP_MAPPING"
                mv "$TEMP_MAPPING" "$MAPPING_FILE"
                
                echo "  Added to core and mapping"
            fi
            ((NEW_FILES++)) || true
        fi
    done
fi

echo ""
echo "Summary:"
echo "  Copied: $COPIED"
echo "  New files: $NEW_FILES"
echo "  Deleted: $DELETED_FILES"
echo "  Unchanged: $UNCHANGED"
echo "  Skipped: $SKIPPED"
echo ""

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}Dry run complete. No changes were made.${NC}"
    echo ""
    echo "To apply changes, run without --dry-run:"
    echo "  npm run sync:to-core"
    echo ""
    echo "To include new files:"
    echo "  npm run sync:to-core -- --include-new"
    echo ""
    echo "To delete files removed from plugin:"
    echo "  npm run sync:to-core -- --include-deleted"
    echo ""
    echo "To create a branch in core:"
    echo "  npm run sync:to-core -- --branch admin-reskin/your-feature"
    exit 0
fi

if [ -n "$BRANCH_NAME" ]; then
    echo -e "${GREEN}Changes copied to branch '$BRANCH_NAME' in core.${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. cd $CORE_PATH"
    echo "  2. Review the changes: git diff"
    echo "  3. Commit: git add -A && git commit -m 'Your commit message'"
    echo "  4. Create PR or patch for Trac"
fi

echo ""
echo -e "${GREEN}Sync to core complete!${NC}"
