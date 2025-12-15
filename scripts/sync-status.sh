#!/bin/bash
#
# Show sync status for forked stylesheets
#
# This script shows the current synchronization status between the forked
# stylesheets and WordPress core, including new and deleted files.
#
# Usage: npm run sync:status
#        or: bash scripts/sync-status.sh
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

# Read last sync commit from mapping file
LAST_SYNC=$(jq -r '.lastSyncCommit' "$MAPPING_FILE")

echo -e "${BLUE}=== Admin Redesign Fork Status ===${NC}"
echo ""

# Check if core repo exists
if [ ! -d "$CORE_PATH" ]; then
    echo -e "${RED}Error: WordPress core repository not found at $CORE_PATH${NC}"
    echo "Please check your .env configuration (CORE_REPO_PATH)."
    exit 1
fi

echo "Core Repository: $CORE_PATH"
echo "Core Branch: $CORE_BRANCH"
echo ""

# Get current commit SHA from core
cd "$CORE_PATH"
CURRENT_COMMIT=$(git rev-parse HEAD)
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
CURRENT_DATE=$(git log -1 --format=%ci HEAD)

echo -e "${BLUE}Core Status:${NC}"
echo "  Current branch: $CURRENT_BRANCH"
echo "  Current commit: $CURRENT_COMMIT"
echo "  Commit date: $CURRENT_DATE"
echo ""

# Check last sync status
if [ "$LAST_SYNC" == "null" ] || [ -z "$LAST_SYNC" ]; then
    echo -e "${YELLOW}Fork Status: NOT INITIALIZED${NC}"
    echo ""
    echo "Run 'npm run sync:init' to initialize the fork."
    exit 0
fi

LAST_SYNC_DATE=$(git log -1 --format=%ci "$LAST_SYNC" 2>/dev/null || echo "unknown")

echo -e "${BLUE}Fork Status:${NC}"
echo "  Last sync commit: $LAST_SYNC"
echo "  Last sync date: $LAST_SYNC_DATE"
echo ""

# Define tracked directories
TRACKED_DIRS=(
    "src/wp-admin/css"
    "src/wp-includes/css"
)

if [ "$LAST_SYNC" == "$CURRENT_COMMIT" ]; then
    echo -e "${GREEN}Status: UP TO DATE${NC}"
else
    # Count commits behind
    COMMITS_BEHIND=$(git rev-list --count "$LAST_SYNC".."$CURRENT_COMMIT" 2>/dev/null || echo "unknown")
    
    echo -e "${YELLOW}Status: $COMMITS_BEHIND commit(s) behind${NC}"
    echo ""
    
    # Show changed files
    echo -e "${BLUE}Changed files in core since last sync:${NC}"
    
    cd "$PLUGIN_DIR"
    TRACKED_PATHS=$(jq -r '.files | keys[]' "$MAPPING_FILE")
    cd "$CORE_PATH"
    
    CHANGED=0
    for core_path in $TRACKED_PATHS; do
        CHANGES=$(git diff --name-only "$LAST_SYNC".."$CURRENT_COMMIT" -- "$core_path" 2>/dev/null || echo "")
        if [ -n "$CHANGES" ]; then
            echo "  M $core_path"
            ((CHANGED++)) || true
        fi
    done
    
    if [ "$CHANGED" -eq 0 ]; then
        echo "  (no changes in tracked files)"
    fi
fi

# Check for new files in core
echo ""
echo -e "${BLUE}New files in core (not in mapping):${NC}"

NEW_IN_CORE=0
for dir in "${TRACKED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        find "$dir" -type f \( -name "*.css" -o -name "*.scss" \) | while read -r core_file; do
            cd "$PLUGIN_DIR"
            if ! jq -e --arg path "$core_file" '.files[$path]' "$MAPPING_FILE" > /dev/null 2>&1; then
                # Check if file was added after last sync
                cd "$CORE_PATH"
                if [ "$LAST_SYNC" != "$CURRENT_COMMIT" ]; then
                    FILE_ADDED=$(git log --oneline "$LAST_SYNC".."$CURRENT_COMMIT" --diff-filter=A -- "$core_file" 2>/dev/null | head -1)
                    if [ -n "$FILE_ADDED" ]; then
                        echo "  + $core_file (new since last sync)"
                        ((NEW_IN_CORE++)) || true
                    fi
                fi
            fi
            cd "$CORE_PATH"
        done
    fi
done

if [ "$NEW_IN_CORE" -eq 0 ]; then
    echo "  (none)"
fi

# Check for deleted files in core
echo ""
echo -e "${BLUE}Deleted files in core (still in mapping):${NC}"

cd "$PLUGIN_DIR"
DELETED_IN_CORE=0

jq -r '.files | keys[]' "$MAPPING_FILE" | while read -r core_path; do
    cd "$CORE_PATH"
    if [ ! -f "$core_path" ]; then
        echo "  - $core_path"
        ((DELETED_IN_CORE++)) || true
    fi
    cd "$PLUGIN_DIR"
done

if [ "$DELETED_IN_CORE" -eq 0 ]; then
    echo "  (none)"
fi

# Check for new files in plugin not in mapping
echo ""
echo -e "${BLUE}New files in plugin (not in mapping):${NC}"

cd "$PLUGIN_DIR"
NEW_IN_PLUGIN=0

find "$PLUGIN_DIR/core-styles" -type f \( -name "*.css" -o -name "*.scss" \) 2>/dev/null | while read -r plugin_file; do
    plugin_path="${plugin_file#$PLUGIN_DIR/}"
    # Convert to core path
    core_path="src/${plugin_path#core-styles/}"
    
    if ! jq -e --arg path "$core_path" '.files[$path]' "$MAPPING_FILE" > /dev/null 2>&1; then
        echo "  + $plugin_path"
        ((NEW_IN_PLUGIN++)) || true
    fi
done

if [ "$NEW_IN_PLUGIN" -eq 0 ]; then
    echo "  (none)"
fi

# Check for missing files in plugin (in mapping but not on disk)
echo ""
echo -e "${BLUE}Missing files in plugin (in mapping but deleted):${NC}"

MISSING_IN_PLUGIN=0
jq -r '.files | to_entries[] | .value.plugin' "$MAPPING_FILE" | while read -r plugin_path; do
    if [ ! -f "$PLUGIN_DIR/$plugin_path" ]; then
        echo "  - $plugin_path"
        ((MISSING_IN_PLUGIN++)) || true
    fi
done

if [ "$MISSING_IN_PLUGIN" -eq 0 ]; then
    echo "  (none)"
fi

# File counts
echo ""
echo -e "${BLUE}File Counts:${NC}"

TOTAL_TRACKED=$(jq '.files | length' "$MAPPING_FILE")
FORKED=$(find "$PLUGIN_DIR/core-styles" -type f \( -name "*.css" -o -name "*.scss" \) 2>/dev/null | wc -l | tr -d ' ')

echo "  Tracked in mapping: $TOTAL_TRACKED"
echo "  Files in core-styles: $FORKED"

# Next steps
echo ""
if [ "$LAST_SYNC" != "$CURRENT_COMMIT" ]; then
    echo "Run 'npm run sync:update' to pull changes from core."
    echo "Run 'npm run sync:update -- --dry-run' to preview changes first."
fi
