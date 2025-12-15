#!/bin/bash
#
# Shared environment configuration loader for sync scripts
#
# This script loads configuration from .env file and prompts
# for setup if not configured.
#
# Usage: source scripts/lib/env-config.sh
#

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory and plugin root
# Note: This assumes the script sourcing this is in scripts/
if [ -z "$PLUGIN_DIR" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
    PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
fi

ENV_FILE="$PLUGIN_DIR/.env"
ENV_EXAMPLE="$PLUGIN_DIR/.env.example"

# Function to prompt for configuration
prompt_for_config() {
    echo -e "${BLUE}=== Admin Redesign - First Time Setup ===${NC}"
    echo ""
    echo "This plugin needs to know where your WordPress core repository is located."
    echo ""
    
    # Default value
    local default_path="../wordpress-develop"
    local default_branch="trunk"
    
    # Prompt for core repo path
    echo -e "${YELLOW}Enter the path to your WordPress core repository (wordpress-develop):${NC}"
    echo -e "  (relative to this plugin, or absolute path)"
    echo -n "  [$default_path]: "
    read -r input_path
    
    # Use default if empty
    local core_path="${input_path:-$default_path}"
    
    # Resolve and validate the path
    if [[ "$core_path" == /* ]]; then
        resolved_path="$core_path"
    else
        resolved_path="$PLUGIN_DIR/$core_path"
    fi
    
    # Check if it exists
    if [ ! -d "$resolved_path" ]; then
        echo ""
        echo -e "${YELLOW}Warning: Directory not found at $resolved_path${NC}"
        echo -n "Continue anyway? [y/N]: "
        read -r confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo -e "${RED}Setup cancelled.${NC}"
            exit 1
        fi
    elif [ ! -d "$resolved_path/.git" ]; then
        echo ""
        echo -e "${YELLOW}Warning: $resolved_path doesn't appear to be a git repository${NC}"
        echo -n "Continue anyway? [y/N]: "
        read -r confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo -e "${RED}Setup cancelled.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}✓ Found WordPress core at $resolved_path${NC}"
    fi
    
    echo ""
    
    # Prompt for branch
    echo -e "${YELLOW}Enter the branch to sync from:${NC}"
    echo -n "  [$default_branch]: "
    read -r input_branch
    
    local core_branch="${input_branch:-$default_branch}"
    
    echo ""
    
    # Write .env file
    cat > "$ENV_FILE" << EOF
# Admin Redesign Exploration - Environment Configuration
# Generated on $(date)

# Path to WordPress core repository (wordpress-develop)
CORE_REPO_PATH=$core_path

# Branch to sync from
CORE_BRANCH=$core_branch
EOF
    
    echo -e "${GREEN}✓ Configuration saved to .env${NC}"
    echo ""
    
    # Export the variables
    export CORE_REPO_PATH="$core_path"
    export CORE_BRANCH="$core_branch"
}

# Function to load .env file
load_env() {
    if [ -f "$ENV_FILE" ]; then
        # Source the .env file
        set -a
        source "$ENV_FILE"
        set +a
        return 0
    fi
    return 1
}

# Function to validate configuration
validate_config() {
    local errors=0
    
    if [ -z "$CORE_REPO_PATH" ]; then
        echo -e "${RED}Error: CORE_REPO_PATH is not set${NC}"
        errors=1
    fi
    
    if [ -z "$CORE_BRANCH" ]; then
        echo -e "${YELLOW}Warning: CORE_BRANCH is not set, defaulting to 'trunk'${NC}"
        export CORE_BRANCH="trunk"
    fi
    
    return $errors
}

# Function to resolve core path
resolve_core_path() {
    if [[ "$CORE_REPO_PATH" == /* ]]; then
        echo "$CORE_REPO_PATH"
    else
        echo "$PLUGIN_DIR/$CORE_REPO_PATH"
    fi
}

# Main configuration loading logic
load_config() {
    # Try to load existing .env
    if load_env; then
        if validate_config; then
            CORE_PATH=$(resolve_core_path)
            export CORE_PATH
            return 0
        fi
    fi
    
    # No .env or invalid config - prompt for setup
    echo ""
    echo -e "${YELLOW}No configuration found.${NC}"
    echo ""
    
    # Check if we're in an interactive terminal
    if [ -t 0 ]; then
        prompt_for_config
        CORE_PATH=$(resolve_core_path)
        export CORE_PATH
    else
        echo -e "${RED}Error: No .env file found and not running interactively.${NC}"
        echo ""
        echo "Please create a .env file with the following content:"
        echo ""
        echo "  CORE_REPO_PATH=../wordpress-develop"
        echo "  CORE_BRANCH=trunk"
        echo ""
        echo "Or copy .env.example to .env and edit it:"
        echo "  cp .env.example .env"
        echo ""
        exit 1
    fi
}

# Automatically load config when sourced
load_config

