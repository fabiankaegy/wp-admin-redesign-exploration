# View transitions

## Why this matters

View transitions can reduce perceived jank when navigating between admin screens. This is useful because wp-admin navigation is frequent. One thing to keep in mind is that motion can be distracting or uncomfortable for some users, so reduced motion support is required.

## Scope

CSS only view transitions for cross document navigation in wp-admin, implemented as progressive enhancement.

## Non goals

- No JavaScript changes.
- No new markup.
- No new CSS custom properties.

## Requirements

### Progressive enhancement

- Enable transitions only where the browser supports them.
- Avoid transitions on heavy or complex pages if performance is impacted.

### Reduced motion

- Respect `prefers-reduced-motion: reduce` and disable transitions in that mode.

### Accessibility and usability

- Do not interfere with focus restoration or keyboard navigation.
- Avoid transitions that mask loading states.

## Deliverables

- A CSS implementation that adds view transitions safely.
- A short note describing which pages and browsers are expected to receive the effect.

## Discussion checkpoints

### Shipping policy

Decisions to capture:

- Whether view transitions are enabled by default in 7.0.
- If not enabled by default, what the opt in mechanism is (must be CSS only).

## Acceptance criteria

- Transitions are disabled for reduced motion users.
- No regressions in navigation or focus behavior.
- No new CSS custom properties were introduced.

## Testing notes

- Test navigation between:
  - Dashboard and Posts list
  - Settings pages
- Test with reduced motion enabled.

