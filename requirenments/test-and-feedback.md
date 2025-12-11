# Test and feedback

## Why this matters

Shipping a reskin into trunk requires early and repeated feedback. This step defines what to test, who to ask, and how to interpret feedback so the project can move quickly without destabilizing wp-admin. This is useful because it keeps the feedback cycle focused on real editor workflows instead of abstract opinions.

## Scope

- Define a repeatable test matrix for core screens.
- Define admin color scheme validation.
- Define plugin compatibility testing expectations.
- Define RTL checks and locale checks.
- Define how issues are reported and triaged.

## Non goals

- No new automated infrastructure is required to start.
- No large scale visual regression tooling is required for the first iteration.

## Requirements

### Core screen matrix

Minimum smoke list:

- Dashboard
- Posts list
- Post editor
- Media library
- Appearance themes
- Plugins list
- Settings general
- Users list

### Color scheme coverage

- Test all bundled admin color schemes at least once per milestone.
- At minimum, always test:
  - `admin-color-modern`
  - `admin-color-light`

### Plugin compatibility coverage

Target plugin categories:

- SEO
- Commerce
- Forms
- Page builders
- Security

Define what constitutes a regression:

- Broken layout that prevents task completion
- Inaccessible focus state
- Contrast failures
- Overlapping or clipped critical UI controls

### RTL and locale checks

- Validate RTL output does not produce broken layout.
- Spot check one RTL locale for key screens.

### Feedback template

Provide a copy paste template for testers:

- WordPress version or revision
- Browser and OS
- Admin scheme
- Screen URL and steps to reproduce
- Screenshot
- Expected result and actual result

Let’s look at an example:

```text
WP version: 7.0-alpha-12345
Browser and OS: Chrome 131 on macOS 15
Admin scheme: modern
Screen: /wp-admin/edit.php
Steps:
1. Select two posts.
2. Open Bulk actions dropdown.
3. Click Apply.
Expected: Dropdown and Apply button remain aligned and focus ring is visible.
Actual: Apply button focus ring is clipped.
Screenshot: attached
```

## Deliverables

- A test matrix document suitable for posting in a call for testing.
- A triage rubric for categorizing issues.
- A cadence plan for test milestones.

## Discussion checkpoints

### Testing depth before merge

Decisions to capture:

- What level of plugin testing is required for each milestone.
- What issues block further rollout.

## Acceptance criteria

- Test matrix exists and is shared with contributors.
- Call for testing template exists.
- A clear definition of regression is agreed.

