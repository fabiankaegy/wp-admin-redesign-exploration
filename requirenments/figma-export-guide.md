# Design System Export Guide

This document lists all components needed for the admin reskin requirements documentation.

## Storybook Screenshots (Automated)

We have automated screenshots from the [Gutenberg Storybook](https://wordpress.github.io/gutenberg/) saved to `requirenments/images/storybook/`.

**44 components captured**, including:
- Buttons (default, primary, secondary, tertiary, link, icon)
- Inputs (text, textarea, number, search, select, checkbox, radio, toggle)
- Notices (default, with actions, snackbar)
- Cards (default, panel, surface)
- Navigation (tabs, navigation)
- Feedback (spinner, progress bar)
- Typography (heading, text, truncate)
- Modals (modal, confirm dialog, popover, dropdown, tooltip)
- Forms (token field, date picker, time picker, color picker)

To regenerate, run:
```bash
node scripts/capture-storybook-screenshots.js
```

## Figma Exports (Manual)

For components not available in Storybook, or for specific design specs, export from Figma.

**Base Figma URL:** https://www.figma.com/design/804HN2REV2iap2ytjRQ055/WordPress-Design-System

## Export Settings

For all exports, use the following settings:

| Setting | Value |
|---------|-------|
| Format | PNG |
| Scale | 2x or 3x (for retina) |
| Background | Include background (or transparent where appropriate) |

## Output Directory

Save all exported images to:

```
requirenments/images/figma/
```

## Components to Export

### Buttons

**Figma Link:** [Button component](https://www.figma.com/design/804HN2REV2iap2ytjRQ055/WordPress-Design-System?node-id=16507-33913)

| Component | States to capture | Filename |
|-----------|-------------------|----------|
| Primary Button | Default | `figma-button-primary-default.png` |
| Primary Button | Hover | `figma-button-primary-hover.png` |
| Primary Button | Active/Pressed | `figma-button-primary-active.png` |
| Primary Button | Focus | `figma-button-primary-focus.png` |
| Primary Button | Disabled | `figma-button-primary-disabled.png` |
| Secondary Button | Default | `figma-button-secondary-default.png` |
| Secondary Button | Hover | `figma-button-secondary-hover.png` |
| Secondary Button | Focus | `figma-button-secondary-focus.png` |
| Secondary Button | Disabled | `figma-button-secondary-disabled.png` |
| Tertiary Button | Default | `figma-button-tertiary-default.png` |
| Tertiary Button | Hover | `figma-button-tertiary-hover.png` |
| Link Button | Default | `figma-button-link-default.png` |
| Link Button | Hover | `figma-button-link-hover.png` |
| Destructive Button | Default | `figma-button-destructive-default.png` |
| Button Sizes | All sizes comparison | `figma-button-sizes.png` |
| Focus Ring | Close-up of focus ring | `figma-button-focus-ring.png` |

### Inputs

**Figma Link:** [Text Input component](https://www.figma.com/design/804HN2REV2iap2ytjRQ055/WordPress-Design-System?node-id=3343-36298)

| Component | States to capture | Filename |
|-----------|-------------------|----------|
| Text Input | Default/Empty | `figma-input-text-default.png` |
| Text Input | With value | `figma-input-text-filled.png` |
| Text Input | Focus | `figma-input-text-focus.png` |
| Text Input | Disabled | `figma-input-text-disabled.png` |
| Text Input | Read-only | `figma-input-text-readonly.png` |
| Text Input | Error/Invalid | `figma-input-text-error.png` |
| Input Sizes | Large vs Medium comparison | `figma-input-sizes.png` |
| Select | Default | `figma-input-select-default.png` |
| Select | Open/Expanded | `figma-input-select-open.png` |
| Select | Disabled | `figma-input-select-disabled.png` |
| Textarea | Default | `figma-input-textarea-default.png` |
| Checkbox | Unchecked | `figma-input-checkbox-unchecked.png` |
| Checkbox | Checked | `figma-input-checkbox-checked.png` |
| Checkbox | Indeterminate | `figma-input-checkbox-indeterminate.png` |
| Checkbox | Disabled | `figma-input-checkbox-disabled.png` |
| Radio | Unselected | `figma-input-radio-unselected.png` |
| Radio | Selected | `figma-input-radio-selected.png` |
| Radio | Disabled | `figma-input-radio-disabled.png` |
| Focus Ring | Input focus ring detail | `figma-input-focus-ring.png` |

### Notices

**Figma Link:** [Notice component](https://www.figma.com/design/804HN2REV2iap2ytjRQ055/WordPress-Design-System?node-id=15877-6195)

| Component | Variant | Filename |
|-----------|---------|----------|
| Notice | Info | `figma-notice-info.png` |
| Notice | Success | `figma-notice-success.png` |
| Notice | Warning | `figma-notice-warning.png` |
| Notice | Error | `figma-notice-error.png` |
| Notice | With dismiss button | `figma-notice-dismissible.png` |
| Notice | With action buttons | `figma-notice-with-actions.png` |
| Dismiss Button | Close button detail | `figma-notice-dismiss-button.png` |

### Cards

**Figma Link:** [Card component](https://www.figma.com/design/804HN2REV2iap2ytjRQ055/WordPress-Design-System?node-id=16532-44253)

| Component | Variant | Filename |
|-----------|---------|----------|
| Card | Basic (Small padding) | `figma-card-small.png` |
| Card | Medium padding | `figma-card-medium.png` |
| Card | Large padding | `figma-card-large.png` |
| Card | With header | `figma-card-with-header.png` |
| Card | With footer | `figma-card-with-footer.png` |
| Card | With header and footer | `figma-card-full.png` |
| Card | With media section | `figma-card-with-media.png` |
| Card Sizes | Padding comparison | `figma-card-sizes.png` |

### Tables / DataViews

**Figma Link:** Look for DataViews or Table components in the design system

| Component | Variant | Filename |
|-----------|---------|----------|
| Table Header | Default | `figma-table-header.png` |
| Table Row | Default | `figma-table-row-default.png` |
| Table Row | Hover | `figma-table-row-hover.png` |
| Table Row | Selected | `figma-table-row-selected.png` |
| Table | Compact density | `figma-table-density-compact.png` |
| Table | Balanced density | `figma-table-density-balanced.png` |
| Table | Comfortable density | `figma-table-density-comfortable.png` |
| Checkbox Column | In table context | `figma-table-checkbox-column.png` |
| Sortable Header | With sort indicator | `figma-table-sortable-header.png` |

### Typography

**Figma Link:** Look for Typography section in the design system (node-id=551-29619 or similar)

| Component | Variant | Filename |
|-----------|---------|----------|
| Heading 2XL | 32px/40px | `figma-type-heading-2xl.png` |
| Heading XL | 20px/24px | `figma-type-heading-xl.png` |
| Heading Large | 15px/20px | `figma-type-heading-large.png` |
| Heading Medium | 13px/20px | `figma-type-heading-medium.png` |
| Heading Small | 11px/16px uppercase | `figma-type-heading-small.png` |
| Body XL | 20px/32px | `figma-type-body-xl.png` |
| Body Large | 15px/24px | `figma-type-body-large.png` |
| Body Medium | 13px/20px | `figma-type-body-medium.png` |
| Body Small | 12px/16px | `figma-type-body-small.png` |
| Typography Scale | Full scale overview | `figma-type-scale.png` |

### Colors and Tokens

**Figma Link:** Look for Color/Token section in the design system

| Component | Variant | Filename |
|-----------|---------|----------|
| Gray Scale | Full gray palette | `figma-colors-gray-scale.png` |
| Theme Colors | Brand/accent colors | `figma-colors-theme.png` |
| Semantic Colors | Info, success, warning, error | `figma-colors-semantic.png` |
| Spacing Scale | 4px grid tokens | `figma-spacing-scale.png` |
| Border Radius | Radius tokens | `figma-radius-tokens.png` |

### Navigation Components

**Figma Link:** Look for Navigation or Tabs components

| Component | Variant | Filename |
|-----------|---------|----------|
| Nav Tabs | Default | `figma-nav-tabs.png` |
| Nav Tab | Active state | `figma-nav-tab-active.png` |
| Nav Tab | Hover state | `figma-nav-tab-hover.png` |
| Filter Links | Horizontal filter bar | `figma-nav-filter-links.png` |
| View Switcher | Grid/List toggle | `figma-nav-view-switcher.png` |

### Feedback Components

**Figma Link:** Look for Spinner, Progress, or Feedback components

| Component | Variant | Filename |
|-----------|---------|----------|
| Spinner | Default | `figma-feedback-spinner.png` |
| Progress Bar | Determinate | `figma-feedback-progress.png` |
| Progress Bar | Indeterminate | `figma-feedback-progress-indeterminate.png` |

### Focus States

These are critical for accessibility documentation.

| Component | Variant | Filename |
|-----------|---------|----------|
| Focus Ring | General focus ring spec | `figma-focus-ring-spec.png` |
| Focus Ring | On button | `figma-focus-ring-button.png` |
| Focus Ring | On input | `figma-focus-ring-input.png` |
| Focus Ring | On checkbox | `figma-focus-ring-checkbox.png` |

## After Export

Once all images are exported to `requirenments/images/figma/`, let me know and I can update all the requirements documents to reference them with proper sizing.

## Checklist

Use this checklist to track export progress:

- [ ] Buttons (16 images)
- [ ] Inputs (18 images)
- [ ] Notices (7 images)
- [ ] Cards (8 images)
- [ ] Tables (9 images)
- [ ] Typography (10 images)
- [ ] Colors and Tokens (5 images)
- [ ] Navigation (5 images)
- [ ] Feedback (3 images)
- [ ] Focus States (4 images)

**Total: ~85 images**

