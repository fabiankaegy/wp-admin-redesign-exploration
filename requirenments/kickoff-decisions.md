# Kickoff decisions

## Why this matters

This step creates clarity and reduces churn. A coat of paint touches many screens and will attract feedback. This is useful because clear scope and guardrails protect editor experience, preserve markup parity, and keep the work maintainable for Core.

## Scope

- Define what is in scope for the WordPress 7.0 admin coat of paint.
- Confirm trunk first delivery and patch sizing strategy.
- Define project guardrails and acceptance criteria.
- Define communication and feedback cadence.

## Non goals

- No markup changes in PHP.
- No JavaScript changes.
- No new information architecture changes.
- No functional changes to admin features.

## Requirements

### Delivery and patch sizing

It is recommended to keep patches small enough that a reviewer can understand the intent and the risk in one sitting.

- **Patch sizing**: land changes in small, reviewable patches.
- **Revert strategy**: keep each component group independently revertable.
- **Early patches**: start with low-risk changes that are mostly additive in effect where possible.

### CSS custom properties policy

One thing to keep in mind is that any CSS custom property introduced in Core is effectively a public contract. You can do this, but it is not recommended unless the project is willing to support it long-term.

- **No new custom properties**: do not introduce new CSS custom properties beyond the admin scheme variables already exposed globally.
- **Tokenization**: if additional tokenization is needed, use Sass variables and mixins compiled into static CSS.
- **Rationale**: this protects long-term maintainability and reduces compatibility risk for plugins.

### Source of truth and tracking

- Create a single umbrella ticket and child tickets per component group:
  - Token foundation
  - Buttons
  - Inputs
  - Notices
  - Cards
  - Tables
  - Typography
  - Spacing
  - Background
  - Admin frame (optional)
  - View transitions

### Acceptance criteria (project level)

- **Visual-only**: visual only change, no behavior changes.
- **Markup parity**: existing class names remain valid and no new wrappers are required.
- **Color schemes**: admin color schemes remain supported.
- **Accessibility**: keyboard focus remains visible and accessible.
- **Reduced motion**: reduced motion is respected for any animation or transition work.

## Deliverables

- Scope statement for WordPress 7.0.
- Patch sequencing plan and revert strategy.
- Testing and feedback plan outline.
- Decision log entry recording the above.

## Discussion checkpoints

### Scope agreement

Decisions to capture:

- Which components are in scope for 7.0.
- Whether admin frame restyling is in scope or deferred.

### View transitions policy

Decisions to capture:

- Whether view transitions ship by default or behind an opt in.
- What browsers receive the effect as progressive enhancement.

### Plugin compatibility expectations

Decisions to capture:

- What level of breakage is considered a regression.
- Which plugin categories will be targeted for testing.

## Acceptance criteria

- Umbrella ticket and child tickets exist and are linked.
- A written scope statement exists and matches the constraints.
- A patch sizing and revert plan exists and is agreed by stakeholders.
- CSS custom properties policy is documented for contributors.

## Testing notes

- None for this step beyond documentation review.

