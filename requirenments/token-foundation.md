# Token foundation

## Why this matters

A coat of paint succeeds when the admin feels consistent. Tokens are the mechanism that lets us apply sensible defaults across buttons, inputs, notices, tables, and cards without duplicating hardcoded values. This is useful because it reduces drift over time, improves maintainability, and helps keep the editor experience coherent.

## Scope

- Establish Sass based token maps for typography, spacing, radii, elevation, and neutrals.
- Consume the existing globally exposed admin scheme CSS custom properties for theme color and focus width.
- Update core admin component styles to use Sass tokens and the existing CSS custom properties, compiled into static CSS.

## Non goals

- Do not expose new CSS custom properties beyond the existing admin scheme ones.
- Do not change markup or add new classes.
- Do not change color scheme definitions beyond the patch that already exposes theme color variables.

## Inputs

### Existing global CSS custom properties

These are available on all admin screens via compiled CSS output:

- `--wp-admin-theme-color`
- `--wp-admin-theme-color--rgb`
- `--wp-admin-theme-color-darker-10`
- `--wp-admin-theme-color-darker-10--rgb`
- `--wp-admin-theme-color-darker-20`
- `--wp-admin-theme-color-darker-20--rgb`
- `--wp-admin-border-width-focus`

Let’s look at an example:

```css
/* Example only. Use existing selectors. */
.wp-core-ui .button:focus {
	box-shadow: 0 0 0 var(--wp-admin-border-width-focus) rgba(var(--wp-admin-theme-color--rgb), 0.3);
}
```

### Design system references

- Figma design system file: `https://www.figma.com/design/804HN2REV2iap2ytjRQ055/WordPress-Design-System`
- Relevant token families:
  - Spacing units (grid units 4, 8, 12, 16, 24, 32, 40, 48)
  - Radii (2, 4, 8)
  - Elevation presets
  - Typography scale (body and heading sizes)

### Figma token to Sass mapping

#### Spacing (grid units)

| Figma token | Value | Sass variable |
|-------------|-------|---------------|
| `scales/grid-unit-05` | 4px | `$spacing-05` |
| `scales/grid-unit-10` | 8px | `$spacing-10` |
| `scales/grid-unit-15` | 12px | `$spacing-15` |
| `scales/grid-unit-20` | 16px | `$spacing-20` |
| `scales/grid-unit-30` | 24px | `$spacing-30` |
| `scales/grid-unit-40` | 32px | `$spacing-40` |

#### Border radius

| Figma token | Value | Sass variable |
|-------------|-------|---------------|
| `radius-xs` | 1px | `$radius-xs` |
| `radius-s` | 2px | `$radius-s` |
| `radius-05` | 4px | `$radius-m` |
| `radius-l` | 8px | `$radius-l` |

#### Gray scale

| Figma token | Value | Sass variable |
|-------------|-------|---------------|
| `scales/grays/gray-100` | #f0f0f0 | `$gray-100` |
| `scales/grays/gray-400` | #cccccc | `$gray-400` |
| `scales/grays/gray-600` | #949494 | `$gray-600` |
| `scales/grays/gray-900` | #1e1e1e | `$gray-900` |
| `scales/black-&-white/white` | #ffffff | `$white` |

#### Semantic colors

| Figma token | Value | Sass variable |
|-------------|-------|---------------|
| `scales/yellow/alert-yellow` | #f0b849 | `$color-warning` |
| `scales/green/alert-green` | #4ab866 | `$color-success` |
| `scales/red/alert-red` | #cc1818 | `$color-error` |
| `scales/brand-9` | #4465db | `$color-focus` |

#### Typography

| Figma token | Value | Sass variable |
|-------------|-------|---------------|
| `m` (font size) | 13px | `$font-size-base` |
| `s` (line height) | 20px | `$line-height-base` |
| `regular` (weight) | 400 | `$font-weight-regular` |
| `medium` (weight) | 500 | `$font-weight-medium` |

## Requirements

### Sass token architecture

It is recommended to keep token files small and purpose-driven. This pattern shows up repeatedly in Core CSS work because it makes incremental change safer.

- Define Sass tokens as variables and maps, grouped by purpose:
  - Typography: font families, sizes, line heights, weights
  - Spacing: paddings and gaps
  - Radii: small, medium, large
  - Elevation: shadow definitions
  - Neutrals: surface, border, text, muted text
  - Semantic colors: success, warning, error, info

### Usage rules

- **Accent color**: theme color usage should come from `--wp-admin-theme-color` and its derivatives.
- **Focus width**: focus ring width should use `--wp-admin-border-width-focus`.
- **Everything else**: resolve at build time via Sass and produce static CSS.

### Compatibility rules

One thing to keep in mind is that wp-admin is a long-lived surface area with many plugins layering custom styles.

- Do not require new markup or new wrappers.
- Avoid changes that assume a different DOM structure.
- Keep selector specificity stable where possible.

## Deliverables

- A set of Sass tokens and mixins that can be imported by admin styles.
- A short contributor note describing how to choose tokens.
- A mapping table from Figma tokens to Sass tokens.

## Discussion checkpoints

### Token scope agreement

Questions to resolve:

- Which token families are required for 7.0 (minimum set).
- Whether elevations should be used widely or limited to cards only.

### Neutral palette approach

Questions to resolve:

- Which neutral values are safe to bake into static CSS without breaking schemes.
- Whether any neutrals should be scheme dependent in the future (but not as CSS vars).

## Acceptance criteria

- A token file structure exists and is used by at least one component patch.
- No new CSS custom properties are introduced.
- Existing scheme variables are consumed in at least:
  - focus ring styles
  - primary button styles

## Testing notes

- Confirm that pages load and render without missing variables.
- Confirm that focus styles render consistently across schemes.

