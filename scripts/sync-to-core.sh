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
#

set -e

# Parse arguments first (before sourcing env-config which may prompt)
DRY_RUN=false
SHOW_DIFF=false
BRANCH_NAME=""
CHANGED_ONLY=false

for arg in "$@"; do
    case $arg in
        --dry-run)
            DRY_RUN=true
            ;;
        --diff)
            SHOW_DIFF=true
            ;;
        --branch)
            shift
            BRANCH_NAME="$1"
            ;;
        --branch=*)
            BRANCH_NAME="${arg#*=}"
            ;;
        --changed-only)
            CHANGED_ONLY=true
            ;;
    esac
    shift || true
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

# Process each file in mapping
echo -e "${BLUE}Processing files...${NC}"
echo ""

jq -r '.files | to_entries[] | "\(.key)|\(.value.plugin)"' "$MAPPING_FILE" | while IFS='|' read -r core_path plugin_path; do
    plugin_file="$PLUGIN_DIR/$plugin_path"
    core_file="$CORE_PATH/$core_path"
    
    # Skip if plugin file doesn't exist
    if [ ! -f "$plugin_file" ]; then
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
        echo -e "${GREEN}Would copy${NC}: $plugin_path -> $core_path"
        ((COPIED++)) || true
        continue
    fi
    
    # Create destination directory if needed
    core_dir=$(dirname "$core_file")
    mkdir -p "$core_dir"
    
    # Copy file
    if cp "$plugin_file" "$core_file"; then
        echo -e "${GREEN}COPY${NC}: $plugin_path -> $core_path"
        ((COPIED++)) || true
    else
        echo -e "${RED}FAIL${NC}: $plugin_path"
    fi
done

echo ""
echo "Summary:"
echo "  Copied: $COPIED"
echo "  Unchanged: $UNCHANGED"
echo "  Skipped: $SKIPPED"
echo ""

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}Dry run complete. No changes were made.${NC}"
    echo ""
    echo "To apply changes, run without --dry-run:"
    echo "  npm run sync:to-core"
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

