#!/bin/bash
#
# Show sync status for forked stylesheets
#
# This script shows the current synchronization status between the forked
# stylesheets and WordPress core.
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

if [ "$LAST_SYNC" == "$CURRENT_COMMIT" ]; then
    echo -e "${GREEN}Status: UP TO DATE${NC}"
    echo ""
else
    # Count commits behind
    COMMITS_BEHIND=$(git rev-list --count "$LAST_SYNC".."$CURRENT_COMMIT" 2>/dev/null || echo "unknown")
    
    echo -e "${YELLOW}Status: $COMMITS_BEHIND commit(s) behind${NC}"
    echo ""
    
    # Show changed files
    echo -e "${BLUE}Changed files in core since last sync:${NC}"
    
    cd "$PLUGIN_DIR"
    
    # Get list of tracked paths
    TRACKED_PATHS=$(jq -r '.files | keys[]' "$MAPPING_FILE")
    
    cd "$CORE_PATH"
    
    CHANGED=0
    for core_path in $TRACKED_PATHS; do
        CHANGES=$(git diff --name-only "$LAST_SYNC".."$CURRENT_COMMIT" -- "$core_path" 2>/dev/null || echo "")
        if [ -n "$CHANGES" ]; then
            echo "  - $core_path"
            ((CHANGED++)) || true
        fi
    done
    
    if [ "$CHANGED" -eq 0 ]; then
        echo "  (no changes in tracked files)"
    fi
    
    echo ""
    echo "Run 'npm run sync:update' to pull changes."
    echo "Run 'npm run sync:update -- --dry-run' to preview changes first."
fi

cd "$PLUGIN_DIR"

# Count forked files
echo ""
echo -e "${BLUE}Forked Files:${NC}"

TOTAL_TRACKED=$(jq '.files | length' "$MAPPING_FILE")
FORKED=0

jq -r '.files | to_entries[] | .value.plugin' "$MAPPING_FILE" | while read -r plugin_path; do
    if [ -f "$PLUGIN_DIR/$plugin_path" ]; then
        ((FORKED++)) || true
    fi
done

# Count files that exist
FORKED=$(find "$PLUGIN_DIR/core-styles" -name "*.css" -o -name "*.scss" 2>/dev/null | wc -l | tr -d ' ')

echo "  Tracked in mapping: $TOTAL_TRACKED"
echo "  Actually forked: $FORKED"

