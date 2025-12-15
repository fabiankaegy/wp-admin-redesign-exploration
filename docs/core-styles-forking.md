# Core Styles Forking System

This document explains how the Admin Redesign plugin forks and manages WordPress core stylesheets, allowing CSS changes to be developed in the plugin while maintaining synchronization with upstream core.

## Overview

Since we cannot merge design tweaks directly into WordPress core during development, we need to iterate in a plugin. This system:

1. Copies all relevant CSS files from WordPress core into the plugin
2. Replaces core stylesheets with our forked versions at runtime
3. Maintains a git-based synchronization system to pull upstream changes
4. Provides tooling to copy changes back to core when ready

## How It Works

### The Gutenberg Pattern

This system uses the same approach as the Gutenberg plugin for overriding core styles. Instead of filtering URLs at load time, we hook into `wp_default_styles` at priority 15 (after core registers at priority 10) and deregister/re-register each style handle with our plugin's URL.

```php
// Core registers styles at priority 10
$styles->add( 'common', '/wp-admin/css/common.css' );

// Plugin overrides at priority 15
$styles->remove( 'common' );
$styles->add( 'common', plugin_url( 'core-styles/wp-admin/css/common.css' ) );
$styles->add_data( 'common', 'rtl', 'replace' );
```

This approach has several advantages:

- WordPress handles RTL automatically via `add_data( 'rtl', 'replace' )`
- Dependencies are preserved from the original registration
- Version is controlled explicitly for cache busting
- No URL parsing or edge cases to handle

### Directory Structure

```
wp-admin-redesign-exploration/
├── core-styles/                    # Forked core stylesheets
│   ├── wp-admin/
│   │   └── css/
│   │       ├── common.css          # Main admin styles
│   │       ├── common-rtl.css      # RTL variant
│   │       ├── forms.css
│   │       ├── admin-menu.css
│   │       ├── list-tables.css
│   │       ├── ... (other CSS)
│   │       └── colors/
│   │           ├── _admin.scss     # Shared SCSS
│   │           ├── _variables.scss
│   │           ├── _mixins.scss
│   │           └── [scheme]/       # Color schemes
│   │               ├── colors.css
│   │               ├── colors-rtl.css
│   │               └── colors.scss
│   └── wp-includes/
│       └── css/
│           ├── buttons.css
│           ├── admin-bar.css
│           └── media-views.css
├── includes/
│   └── style-overrides.php         # Runtime style replacement
├── scripts/
│   ├── init-fork.sh                # Initialize fork from core
│   ├── sync-from-core.sh           # Pull upstream changes
│   ├── sync-to-core.sh             # Push changes back to core
│   └── sync-status.sh              # Show sync status
└── file-mapping.json               # Tracks files and sync state
```

## Getting Started

### Prerequisites

- Node.js 20+
- jq (for JSON parsing in shell scripts)
  ```bash
  brew install jq
  ```
- WordPress core repository (wordpress-develop) cloned somewhere on your system

### Initial Setup

1. Clone WordPress core if you haven't already:
   ```bash
   git clone https://github.com/WordPress/wordpress-develop.git ../wordpress-develop
   ```

2. Run the initialization script:
   ```bash
   npm run sync:init
   ```

3. On first run, you'll be prompted to configure the core repository path:
   ```
   === Admin Redesign - First Time Setup ===

   Enter the path to your WordPress core repository (wordpress-develop):
     (relative to this plugin, or absolute path)
     [../wordpress-develop]: 
   ```

   Press Enter to accept the default, or enter a custom path.

4. The configuration is saved to `.env` (gitignored) for future runs.

### Environment Configuration

The core repository path is configured via a `.env` file, allowing different paths per environment.

**To configure manually:**

1. Copy the example file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your settings:
   ```bash
   # Path to WordPress core repository
   CORE_REPO_PATH=../wordpress-develop
   
   # Branch to sync from
   CORE_BRANCH=trunk
   ```

The path can be:
- **Relative**: `../wordpress-develop` (relative to the plugin directory)
- **Absolute**: `/Users/you/code/wordpress-develop`

This copies all tracked CSS files from core and records the current commit SHA.

## Available Commands

| Command | Description |
|---------|-------------|
| `npm run sync:init` | Initialize fork by copying files from core |
| `npm run sync:status` | Show current sync status and changed files |
| `npm run sync:update` | Pull upstream changes using three-way merge |
| `npm run sync:to-core` | Copy changes back to WordPress core |

### Command Options

#### `sync:update`

```bash
npm run sync:update              # Pull and merge changes
npm run sync:update -- --dry-run # Preview without making changes
npm run sync:update -- --force   # Overwrite local changes with core
```

#### `sync:to-core`

```bash
npm run sync:to-core                           # Copy all changed files to core
npm run sync:to-core -- --dry-run              # Preview what would be copied
npm run sync:to-core -- --diff                 # Show diffs of changes
npm run sync:to-core -- --changed-only         # Only copy modified files
npm run sync:to-core -- --branch feature-name  # Create branch in core first
```

## Development Workflow

### Making CSS Changes

1. Edit files in `core-styles/` directly
2. Changes are automatically loaded in WordPress admin (the plugin replaces core stylesheets)
3. Test your changes in the admin

### Staying in Sync with Core

Periodically pull upstream changes to avoid large merge conflicts:

```bash
# Check if there are upstream changes
npm run sync:status

# Pull changes (uses three-way merge)
npm run sync:update
```

If there are merge conflicts, the script will:
1. Apply changes using `git merge-file`
2. Leave standard git conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`)
3. Report which files need manual resolution

### Merging Back to Core

When ready to propose changes for inclusion in WordPress core:

```bash
# Preview what will be synced
npm run sync:to-core -- --dry-run --diff

# Create a branch in core and copy files
npm run sync:to-core -- --branch admin-reskin/buttons

# Then in the core repo:
cd ../wordpress-develop
git diff                    # Review changes
git add -A
git commit -m "Admin: Update button styles for visual refresh"
```

## Configuration Files

### .env (Environment Configuration)

The `.env` file stores your local environment settings. It is gitignored and won't be committed.

```bash
# Path to WordPress core repository
CORE_REPO_PATH=../wordpress-develop

# Branch to sync from
CORE_BRANCH=trunk
```

On first run of any sync script, you'll be prompted to configure this interactively.

### file-mapping.json (File Tracking)

The `file-mapping.json` file tracks which files to sync and the sync state:

- **coreSourceDir**: Directory within core where source files are (`src`)
- **lastSyncCommit**: SHA of the last synced commit
- **files**: Map of core paths to plugin paths

Example:
```json
{
  "version": "1.0.0",
  "coreSourceDir": "src",
  "lastSyncCommit": "abc123...",
  "files": {
    "src/wp-admin/css/common.css": {
      "plugin": "core-styles/wp-admin/css/common.css",
      "handle": "common"
    }
  }
}
```

Note: `coreRepo` and `coreBranch` have been moved to `.env` to allow per-environment configuration.

## Tracked Stylesheets

### Admin CSS (wp-admin/css/)

| Handle | File | Description |
|--------|------|-------------|
| common | common.css | Core admin styles, notices, cards |
| forms | forms.css | Form elements, inputs, checkboxes |
| admin-menu | admin-menu.css | Admin sidebar menu |
| dashboard | dashboard.css | Dashboard widgets |
| list-tables | list-tables.css | WP_List_Table styles |
| edit | edit.css | Post editor (classic) |
| themes | themes.css | Theme browser |
| media | media.css | Media library |
| login | login.css | Login page |

### Includes CSS (wp-includes/css/)

| Handle | File | Description |
|--------|------|-------------|
| buttons | buttons.css | Button styles |
| admin-bar | admin-bar.css | Admin bar (front and back) |
| media-views | media-views.css | Media modal |

### Color Schemes (wp-admin/css/colors/)

All 8 color schemes are tracked:
- modern (default)
- light
- blue
- coffee
- ectoplasm
- midnight
- ocean
- sunrise

Each scheme includes:
- `colors.scss` - Source SCSS
- `colors.css` - Compiled CSS
- `colors-rtl.css` - RTL variant

## SCSS Handling

The color schemes use SCSS. The SCSS files are the source of truth and are synced just like CSS files.

### Building SCSS in the Plugin

The plugin includes build scripts that mirror WordPress core's SCSS compilation:

```bash
# Build all color schemes (SCSS → CSS + RTL)
npm run build

# Build only CSS (no RTL generation)
npm run build:colors

# Watch for SCSS changes during development
npm run watch
```

The build process:
1. **Sass** compiles `.scss` files to `.css` (using dart-sass)
2. **RTLCSS** generates `-rtl.css` variants for RTL languages

### Workflow for SCSS Changes

1. Edit the SCSS files in `core-styles/wp-admin/css/colors/`
2. Build locally: `npm run build`
3. Test in the WP admin
4. When ready, sync back to core: `npm run sync:to-core`

### Quick Development

For active development, run the watch command:

```bash
npm run watch
```

This will automatically recompile SCSS files when they change. Note that `watch` only compiles CSS, not RTL variants. Run `npm run build` before final testing or syncing to core.

## Troubleshooting

### Styles not loading from plugin

1. Check that `style-overrides.php` is being loaded
2. Verify the forked CSS file exists at the expected path
3. Check browser dev tools to see which URL is being loaded

### Merge conflicts during sync

1. Open the conflicted file
2. Look for conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`)
3. Resolve manually by keeping the desired code
4. Run `sync:update` again to update the lastSyncCommit

### jq not found

Install jq:
```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get install jq
```

### Core repository not found

Ensure WordPress core is cloned at the path specified in `file-mapping.json`:
```bash
cd ..
git clone https://github.com/WordPress/wordpress-develop.git
```

## Architecture Reference

### Runtime Flow

```
WordPress Init
    │
    ├── wp_default_styles (priority 10)
    │   └── Core registers: common, forms, admin-menu, etc.
    │
    └── wp_default_styles (priority 15)
        └── Plugin: admin_redesign_register_style_overrides()
            ├── Query registered style
            ├── Remove it
            ├── Re-register with plugin URL
            └── Add RTL data
```

### Sync Flow

```
┌─────────────────┐     sync:init      ┌──────────────────┐
│ WordPress Core  │ ─────────────────► │ Plugin Fork      │
│ (source)        │                    │ (working copy)   │
└─────────────────┘                    └──────────────────┘
         │                                      │
         │         sync:update                  │
         │ ◄──────────────────────────────────► │
         │      (three-way merge)               │
         │                                      │
         │         sync:to-core                 │
         │ ◄─────────────────────────────────── │
         │      (copy back)                     │
         ▼                                      ▼
```

## Related Documentation

- [Tickets and Branching Strategy](../requirenments/tickets-and-branching.md)
- [Button Reskin Requirements](../requirenments/buttons-reskin.md)
- [Input Reskin Requirements](../requirenments/inputs-reskin.md)
- [Gutenberg client-assets.php](https://github.com/WordPress/gutenberg/blob/trunk/lib/client-assets.php)

