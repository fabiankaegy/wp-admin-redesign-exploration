# Commit Message Format

This document defines the standard commit message format for all WordPress 7.0 admin reskin commits.

## Structure

All commit messages should follow this format:

```
Admin UI: [Component] to align with WordPress Design System

[Brief description of what changed and why]

**[Section 1 Title]:**
- [Detail 1]
- [Detail 2]
- [Detail 3]

**[Section 2 Title]:**
- [Detail 1]
- [Detail 2]

**[Additional Sections as needed]**

See: https://core.trac.wordpress.org/ticket/64308
```

## Format Rules

1. **Subject Line:**
   - Start with `Admin UI: `
   - Use present tense (e.g., "Reskin notices" not "Reskinned notices")
   - End with "to align with WordPress Design System"
   - Keep under 72 characters if possible

2. **Body:**
   - Leave one blank line after subject
   - Start with a brief overview paragraph
   - Use blank line before each section
   - Use bold for section headers with colon: `**Section Title:**`
   - Use bullet points (dash + space) for details
   - Include specific values (colors, sizes, spacing)
   - Note what changed from previous state when relevant

3. **Footer:**
   - Always include Trac ticket link
   - Format: `See: https://core.trac.wordpress.org/ticket/64308`

## Example: Notices Reskin

```
Admin UI: Reskin notices to align with WordPress Design System

Update all notice styles to match Gutenberg's component patterns and
the WordPress Design System specifications.

**Base Notice Styles:**
- Border: 4px left border only (removed generic border)
- Box shadow: removed for cleaner appearance
- Padding: 8px 12px (was 1px 12px)
- Typography: 13px/20px, color #1e1e1e (gray-900)

**Notice Type Colors:**
- Info: #3858e9 border, transparent background
- Success: #4ab866 border, #eff9f1 background
- Warning: #f0b849 border, #fef8ee background
- Error: #cc1818 border, #fcf0f0 background

**Dismiss Button:**
- Size: 24px × 24px (was 20px × 20px)
- Position: top 8px, right 12px (improved alignment)
- Color: #1e1e1e (was #787c82)
- Icon size: 20px/24px (was 16px/20px)
- Focus: Gutenberg-style ring using var(--wp-admin-theme-color)
- Hover: opacity 0.7

**Links in Notices:**
- Color: var(--wp-admin-theme-color)
- Hover: var(--wp-admin-theme-color-darker-10)
- Focus: proper focus ring with var(--wp-admin-border-width-focus)

**Spacing:**
- Dismissible notices: 48px right padding (was 38px)
- Provides 24px gap between content and dismiss button

See: https://core.trac.wordpress.org/ticket/64308
```

## Example: Buttons Reskin

```
Admin UI: Reskin buttons to align with WordPress Design System

Update button styles to match Gutenberg's component patterns and adopt
the 40px default height standard.

**Default Button Height:**
- Height: 40px (aligned with Gutenberg's next-default-40px)
- Compact variant: 32px via .button-compact class
- Small variant: 24px for inline contexts

**Primary Button:**
- Background: var(--wp-admin-theme-color)
- Text: #ffffff
- Hover: var(--wp-admin-theme-color-darker-10)
- Active: var(--wp-admin-theme-color-darker-20)

**Secondary Button:**
- Background: transparent
- Border: 1px solid var(--wp-admin-theme-color)
- Text: var(--wp-admin-theme-color)
- Hover: background rgba(var(--wp-admin-theme-color--rgb), 0.04)

**Default/Tertiary Button:**
- Background: transparent
- Border: 1px solid #949494
- Text: #1e1e1e
- Hover: background #f0f0f0

**Focus States:**
- Style: Gutenberg-style outer ring
- Color: var(--wp-admin-theme-color)
- Width: var(--wp-admin-border-width-focus)
- Primary: additional inset white ring for contrast

**Disabled States:**
- Background: transparent
- Text: #949494
- Border: #cccccc
- Cursor: not-allowed

**Border Radius:**
- All buttons: 2px (was 3px)

See: https://core.trac.wordpress.org/ticket/64308
```

## Example: Inputs Reskin

```
Admin UI: Reskin inputs to align with WordPress Design System

Update form input styles to match Gutenberg patterns and adopt the
40px default height standard.

**Input Sizing:**
- Default height: 40px (aligned with Gutenberg's next-default-40px)
- Compact height: 32px for space-constrained contexts
- Uses min-height + line-height (not fixed height) for accessibility

**Text Inputs:**
- Border: 1px solid #949494
- Border radius: 2px
- Background: #ffffff
- Text: 13px/20px, color #1e1e1e
- Padding: 8px horizontal

**Focus States:**
- Style: Gutenberg-style outer ring
- Color: var(--wp-admin-theme-color)
- Width: var(--wp-admin-border-width-focus)
- Border color: var(--wp-admin-theme-color)

**Disabled States:**
- Background: #f0f0f0
- Border: #cccccc
- Text: #949494
- Cursor: not-allowed

**Readonly States:**
- Background: #f0f0f0
- Border: #949494 (maintains default)
- Cursor: default

**Checkboxes:**
- Size: 16px × 16px
- Border: 1px solid #949494
- Border radius: 2px
- Checked: background var(--wp-admin-theme-color)
- Focus: outer ring using var(--wp-admin-theme-color)

**Radio Buttons:**
- Size: 16px × 16px
- Border: 1px solid #949494
- Checked: inner dot using var(--wp-admin-theme-color)
- Focus: outer ring using var(--wp-admin-theme-color)

**Select Dropdowns:**
- Matches text input styling
- Chevron icon: 20px, color #1e1e1e
- Disabled: matches disabled input styling

See: https://core.trac.wordpress.org/ticket/64308
```

## Tips for Writing Good Commit Messages

1. **Be Specific:** Include actual values (colors, sizes, spacing) rather than vague descriptions
2. **Show Changes:** When relevant, note what the previous value was (e.g., "was 20px")
3. **Group Logically:** Organize details into clear sections
4. **Use Consistent Terms:** Match terminology from design system and requirements docs
5. **Reference Variables:** Use CSS custom property names when applicable (e.g., `var(--wp-admin-theme-color)`)
6. **Explain Rationale:** Brief context helps reviewers understand decisions

## What to Include

- Specific measurements (px values, percentages)
- Color values (hex codes, CSS variables)
- State variations (hover, focus, active, disabled)
- Typography details (size, line-height, weight)
- Spacing values (padding, margin, gaps)
- Changes from previous implementation
- Alignment with Gutenberg patterns

## What to Avoid

- Vague descriptions ("improved styling")
- Missing measurements ("made it bigger")
- Unexplained changes
- Implementation details better suited for code comments
- Overly technical jargon when simpler terms work

