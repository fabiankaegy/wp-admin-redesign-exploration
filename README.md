# Admin Redesign Exploration

Contributors: fabiankaegy
Requires at least: 6.7
Tested up to: 6.7.1
Stable tag: 0.1.0
Requires PHP: 8.0
License: GPLv2 or later
License URI: <https://www.gnu.org/licenses/gpl-2.0.html>

[![Playground Demo Link](https://img.shields.io/wordpress/plugin/v/safe-svg?logo=wordpress&logoColor=%23fff&label=Playground%20Demo&labelColor=%233858e9&color=%233858e9)](https://playground.wordpress.net/?blueprint-url=https://raw.githubusercontent.com/fabiankaegy/wp-admin-redesign-exploration/main/_playground/blueprint.json)

> [!WARNING]
> This is an exploratory repository. The goal is to see what the Admin Redesign design actually feels like in a real WordPress environment. This is not a production-ready codebase.

## Overview

This plugin applies CSS tweaks to the WordPress admin based on the Admin Redesign design project. It forks core stylesheets into the plugin, allowing rapid iteration while maintaining easy portability back to core.

## Getting Started

### Prerequisites

- Node.js 20+
- jq (`brew install jq`)
- WordPress core (wordpress-develop) cloned somewhere on your system

### Setup

```bash
# Install dependencies
npm install

# Initialize forked stylesheets from core
# (On first run, you'll be prompted to configure the core repo path)
npm run sync:init

# Start development
npm start
```

### Environment Configuration

The core repository path is stored in `.env` (gitignored). On first run, you'll be prompted to set it up interactively. To configure manually:

```bash
cp .env.example .env
# Edit .env with your core repo path
```

## Core Styles Forking

This plugin uses a forking system that copies WordPress core CSS files into the plugin and replaces them at runtime. This allows us to:

1. Make CSS changes in the plugin
2. Keep changes easily portable to core
3. Stay in sync with upstream core changes

### Available Sync Commands

| Command | Description |
|---------|-------------|
| `npm run sync:init` | Initialize fork by copying CSS from core |
| `npm run sync:status` | Show sync status and changed files |
| `npm run sync:update` | Pull upstream changes (three-way merge) |
| `npm run sync:to-core` | Copy changes back to WordPress core |

### Quick Examples

```bash
# Check if core has updates
npm run sync:status

# Pull upstream changes
npm run sync:update

# Preview what would be synced back to core
npm run sync:to-core -- --dry-run --diff

# Copy changes to a new branch in core
npm run sync:to-core -- --branch admin-reskin/buttons
```

For detailed documentation, see [docs/core-styles-forking.md](docs/core-styles-forking.md).

## Directory Structure

```
├── core-styles/          # Forked WordPress core stylesheets
│   ├── wp-admin/css/     # Admin CSS (common, forms, etc.)
│   └── wp-includes/css/  # Includes CSS (buttons, admin-bar)
├── assets/               # Additional plugin styles/scripts
├── includes/             # PHP includes
│   └── style-overrides.php
├── scripts/              # Sync scripts
├── requirenments/        # Design requirements docs
└── docs/                 # Documentation
```

## Development Workflow

1. Edit CSS files in `core-styles/`
2. Changes load automatically in WP admin
3. Periodically run `sync:update` to pull upstream changes
4. When ready, use `sync:to-core` to copy changes back

## Requirements Documentation

- [Tickets and Branching Strategy](requirenments/tickets-and-branching.md)
- [Button Reskin](requirenments/buttons-reskin.md)
- [Input Reskin](requirenments/inputs-reskin.md)
- [Notice Reskin](requirenments/notices-reskin.md)
- [Table Reskin](requirenments/tables-reskin.md)
- [Card Reskin](requirenments/cards-reskin.md)

## Related Links

- [Trac Ticket #64308](https://core.trac.wordpress.org/ticket/64308)
- [WordPress Design System (Figma)](https://www.figma.com/design/804HN2REV2iap2ytjRQ055/WordPress-Design-System)
- [Gutenberg Storybook](https://wordpress.github.io/gutenberg/)
