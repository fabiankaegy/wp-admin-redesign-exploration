# Requirements

This folder contains one requirements document per implementation step in the admin coat of paint project.

## Design system reference

**Figma:** [WordPress Design System](https://www.figma.com/design/804HN2REV2iap2ytjRQ055/WordPress-Design-System?node-id=551-29619)

The Figma design system contains the visual specifications for all components. Each requirements document includes links to the relevant Figma nodes.

## UI Kit reference

A comprehensive UI Kit page is available in WordPress Develop for visual testing and component reference:

**Access:** `wp-admin/ui-kit.php` (development environments only)

The UI Kit displays all target components with their actual WordPress markup. This is useful for:

- Visual comparison during styling work
- Verifying component states (hover, focus, disabled)
- Checking markup structure before making CSS changes
- Testing across different admin color schemes
- Comparing current WP Admin styling against Figma specifications

### Available component screenshots

| Component | Screenshot |
|-----------|------------|
| Buttons | [buttons.png](./images/buttons.png) |
| Inputs | [inputs.png](./images/inputs.png) |
| Notices | [notices.png](./images/notices.png) |
| Cards | [cards.png](./images/cards.png) |
| Tables | [tables.png](./images/tables.png) |
| Navigation | [navigation.png](./images/navigation.png) |
| Feedback | [feedback.png](./images/feedback.png) |
| Typography | [typography.png](./images/typography.png) |
| Filters | [filters.png](./images/filters.png) |
| Media | [media.png](./images/media.png) |
| Misc | [misc.png](./images/misc.png) |

To regenerate screenshots, run:

```bash
node scripts/capture-screenshots.js
```

## Project constraints

In short, these constraints protect long-term maintainability and avoid breaking expectations for plugins and long-running admin installs.

- **CSS only changes**: no PHP markup changes and no JavaScript changes.
- **Markup parity**: do not rely on new wrappers or new classes. Style what already exists.
- **Backwards compatibility**: existing selectors and admin color schemes must remain supported.
- **CSS custom properties policy**: do not introduce any new CSS custom properties beyond the admin scheme variables already exposed globally. Everything else should be resolved at build time via Sass.

## How to use these docs

Each step document includes:

- Why the step matters
- Component inventory with markup examples
- Where components are used in WP Admin
- Scope and non goals
- Implementation requirements
- Acceptance criteria
- Testing notes
- Discussion checkpoints and open questions

## Steps

1. [Kickoff decisions](kickoff-decisions.md)
2. [Token foundation](token-foundation.md)
3. [Buttons reskin](buttons-reskin.md)
4. [Inputs reskin](inputs-reskin.md)
5. [Notices reskin](notices-reskin.md)
6. [Cards reskin](cards-reskin.md)
7. [Tables reskin](tables-reskin.md)
8. [Background and frame](background-and-frame.md)
9. [View transitions](view-transitions.md)
10. [Test and feedback](test-and-feedback.md)
11. [Docs and merge](docs-and-merge.md)