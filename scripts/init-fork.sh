#!/bin/bash
#
# Initialize forked core stylesheets
#
# This script copies all files defined in file-mapping.json from WordPress core
# to the plugin's core-styles directory. It also records the current core commit
# SHA as lastSyncCommit for future sync operations.
#
# Usage: npm run sync:init
#        or: bash scripts/init-fork.sh
#

set -e

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

# Check if it's a git repository
if [ ! -d "$CORE_PATH/.git" ]; then
    echo -e "${RED}Error: $CORE_PATH is not a git repository${NC}"
    exit 1
fi

echo -e "${GREEN}Initializing forked stylesheets from WordPress core...${NC}"
echo "Core repository: $CORE_PATH"
echo "Core branch: $CORE_BRANCH"
echo ""

# Get current commit SHA from core
cd "$CORE_PATH"
CURRENT_COMMIT=$(git rev-parse HEAD)
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo "Current core commit: $CURRENT_COMMIT"
echo "Current core branch: $CURRENT_BRANCH"
echo ""

# Return to plugin directory
cd "$PLUGIN_DIR"

# Count files to copy
TOTAL_FILES=$(jq '.files | length' "$MAPPING_FILE")
COPIED=0
SKIPPED=0
FAILED=0

echo "Copying $TOTAL_FILES files..."
echo ""

# Iterate through files in mapping
jq -r '.files | to_entries[] | "\(.key)|\(.value.plugin)"' "$MAPPING_FILE" | while IFS='|' read -r core_path plugin_path; do
    source_file="$CORE_PATH/$core_path"
    dest_file="$PLUGIN_DIR/$plugin_path"
    
    # Check if source file exists
    if [ ! -f "$source_file" ]; then
        echo -e "${YELLOW}SKIP${NC}: $core_path (not found in core)"
        ((SKIPPED++)) || true
        continue
    fi
    
    # Create destination directory if needed
    dest_dir=$(dirname "$dest_file")
    mkdir -p "$dest_dir"
    
    # Copy file
    if cp "$source_file" "$dest_file"; then
        echo -e "${GREEN}COPY${NC}: $core_path -> $plugin_path"
        ((COPIED++)) || true
    else
        echo -e "${RED}FAIL${NC}: $core_path"
        ((FAILED++)) || true
    fi
done

echo ""

# Update lastSyncCommit in mapping file
TEMP_FILE=$(mktemp)
jq --arg commit "$CURRENT_COMMIT" '.lastSyncCommit = $commit' "$MAPPING_FILE" > "$TEMP_FILE"
mv "$TEMP_FILE" "$MAPPING_FILE"

echo -e "${GREEN}Updated lastSyncCommit to: $CURRENT_COMMIT${NC}"
echo ""
echo "Initialization complete!"
echo ""
echo "Next steps:"
echo "  1. Review the copied files in core-styles/"
echo "  2. Make your CSS modifications"
echo "  3. Run 'npm run sync:update' periodically to pull upstream changes"

