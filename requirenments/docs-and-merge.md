# Docs and merge

## Why this matters

Landing a visual reskin into Core without clear documentation creates long-term maintenance costs. Documentation helps contributors understand the intent, keeps markup parity, and reduces accidental divergence over time. This pattern shows up repeatedly in Core because it prevents slow regressions after the initial excitement fades.

## Scope

- Document the reskin goals, constraints, and token usage guidance.
- Provide contributor guidance for adding or updating admin UI styles.
- Define how changes are landed in trunk, with a clear changelog and rollout notes.

## Non goals

- No formal design system documentation rewrite.
- No new public CSS custom properties beyond existing admin scheme ones.

## Requirements

### Documentation content

Documents should cover:

- Project scope and non goals
- How to use Sass tokens for spacing, typography, and neutrals
- How and when to use existing scheme CSS variables:
  - `--wp-admin-theme-color*`
  - `--wp-admin-border-width-focus`
- Accessibility requirements and common pitfalls
- Testing instructions and screen matrix

This comes with a few caveats. Avoid framing internal Sass variable names as a public API for plugins. When giving guidance to plugin authors, use stable selectors and the existing scheme custom properties only.

### Changelog and rollout notes

- Each patch series should include:
  - What changed
  - Which screens were validated
  - Known issues and follow ups
- Keep patches separable to allow revert if necessary.

### Contributor guidance

- Provide a short guide for plugin authors who want to align visually without relying on internal Sass.
- Provide guidance on avoiding brittle selectors.

## Deliverables

- A top level README in the exploration repo pointing to requirements docs.
- A changelog template for trunk patches.
- A contributor note describing token usage and constraints.

## Discussion checkpoints

### What documentation ships with 7.0

Decisions to capture:

- Which docs are required before the first reskin patch lands.
- Which docs can land later in the cycle.

## Acceptance criteria

- Documentation exists for each reskin component group.
- A rollout and changelog process is defined.
- No new CSS custom properties are introduced as part of documentation guidance.

