# Tickets and Branching Strategy

This document outlines the individual work items and git branching strategy for the WordPress 7.0 admin reskin project.

## Branching Strategy

```
trunk
  │
  └── feature/admin-reskin-7.0  (Epic branch)
        │
        ├── admin-reskin/token-foundation
        ├── admin-reskin/buttons
        ├── admin-reskin/inputs
        ├── admin-reskin/notices
        ├── admin-reskin/cards
        ├── admin-reskin/tables
        ├── admin-reskin/background
        ├── admin-reskin/admin-menu
        ├── admin-reskin/admin-bar
        └── admin-reskin/typography
```

### Branch Naming Convention

- Epic branch: `feature/admin-reskin-7.0`
- Component branches: `admin-reskin/{component-name}`

### Merge Flow

1. Create component branch from `feature/admin-reskin-7.0`
2. Develop and test component changes
3. Create PR to merge into `feature/admin-reskin-7.0`
4. After all components merged, create PR from `feature/admin-reskin-7.0` to `trunk`

### Testing the Full Reskin

To test all changes together:

```bash
git checkout feature/admin-reskin-7.0
npm run build
```

---

## Tickets

### Epic: Admin Visual Reskin for WordPress 7.0

**Trac:** [#64308](https://core.trac.wordpress.org/ticket/64308)

**Description:** CSS-only visual refresh of wp-admin to align with the WordPress Design System. No markup changes, no JavaScript changes, no new functionality.

**Acceptance Criteria:**
- All 8 admin color schemes work correctly
- WCAG AA contrast requirements met
- RTL layouts function correctly
- No regressions in existing functionality

---

## Phase 1: Foundation

### Ticket 1.1: Token Foundation (Sass Variables)

**Branch:** `admin-reskin/token-foundation`

**Scope:**
- Create `_tokens.scss` partial with design system variables
- Spacing: grid-unit-05 through grid-unit-70
- Border radius: radius-xs through radius-full
- Gray scale: gray-100 through gray-900
- Typography: font sizes, line heights, weights
- Elevation: box-shadow presets

**Files to modify:**
- `src/wp-admin/css/colors/_variables.scss` (add token imports)
- Create `src/wp-admin/css/_tokens.scss` (new file)

**Acceptance Criteria:**
- [ ] Tokens compile without errors
- [ ] No visual changes to admin (tokens only, no usage yet)
- [ ] Tokens documented in code comments

**Estimated effort:** Small (1-2 hours)

---

## Phase 2: Core Components

### Ticket 2.1: Button Reskin

**Branch:** `admin-reskin/buttons`

**Scope:**
- Primary button: theme color background, white text
- Secondary button: white background, theme color border/text
- Tertiary/default button: transparent, gray text
- Link button: theme color text, no background
- Destructive variants: #cc1818 accent
- Focus ring: 1.5px #4465db inset
- Height: 32px (medium)
- Border radius: 2px
- Disabled states: #f0f0f0 background, #949494 text

**Files to modify:**
- `src/wp-admin/css/colors/_admin.scss` (L40-L150)
- `src/wp-admin/css/common.css` (button-related sections)

**Acceptance Criteria:**
- [ ] All button variants match design specs
- [ ] Focus states visible in all color schemes
- [ ] Disabled states clearly distinguishable
- [ ] No layout shifts or size changes

**Estimated effort:** Medium (4-6 hours)

**Requirements doc:** [buttons-reskin.md](./buttons-reskin.md)

---

### Ticket 2.2: Input Reskin

**Branch:** `admin-reskin/inputs`

**Scope:**
- Text inputs: 32px height, 2px radius, #949494 border
- Focus state: 1.5px #4465db inner ring
- Disabled: #f0f0f0 background, #cccccc border
- Readonly: #f0f0f0 background
- Checkboxes: 16px, theme color when checked
- Radio buttons: 16px, theme color when selected
- Select dropdowns: match text input styling
- Textareas: consistent border and focus styling

**Files to modify:**
- `src/wp-admin/css/forms.css` (L34-L200, L825+)
- `src/wp-admin/css/login.css`

**Acceptance Criteria:**
- [ ] All input types have consistent styling
- [ ] Focus rings visible and not clipped
- [ ] Checkbox/radio checked states use theme color
- [ ] Form tables maintain alignment

**Estimated effort:** Medium (4-6 hours)

**Requirements doc:** [inputs-reskin.md](./inputs-reskin.md)

---

### Ticket 2.3: Notice Reskin

**Branch:** `admin-reskin/notices`

**Scope:**
- Structure: 4px left border, 12px/8px padding
- Info: #3858e9 border, white background
- Success: #4ab866 border, #eff9f1 background
- Warning: #f0b849 border, #fef8ee background
- Error: #cc1818 border, light red background
- Dismiss button: 24px, proper focus state
- Legacy `.updated` and `.error` classes

**Files to modify:**
- `src/wp-admin/css/common.css` (L805, L1416-L1500)

**Acceptance Criteria:**
- [ ] All notice variants visually distinct
- [ ] Dismiss button accessible and focusable
- [ ] Legacy classes styled consistently
- [ ] Links inside notices remain visible

**Estimated effort:** Small (2-3 hours)

**Requirements doc:** [notices-reskin.md](./notices-reskin.md)

---

### Ticket 2.4: Card/Postbox Reskin

**Branch:** `admin-reskin/cards`

**Scope:**
- Surface: white background, rgba(0,0,0,0.1) border
- Border radius: 8px for dashboard widgets, 0 for metaboxes
- Padding: 16px (small), 24px (medium)
- Header: bottom border, consistent padding
- Collapse toggle: visible focus state
- Plugin cards: consistent with card system
- Theme cards: consistent with card system

**Files to modify:**
- `src/wp-admin/css/common.css` (L2086-L2260)
- `src/wp-admin/css/dashboard.css` (L33+)
- `src/wp-admin/css/list-tables.css` (L1473 - plugin cards)
- `src/wp-admin/css/themes.css` (L61 - theme cards)

**Acceptance Criteria:**
- [ ] Dashboard widgets have rounded corners
- [ ] Metaboxes maintain square corners
- [ ] Collapse/expand behavior unchanged
- [ ] Card padding consistent across contexts

**Estimated effort:** Medium (4-6 hours)

**Requirements doc:** [cards-reskin.md](./cards-reskin.md)

---

### Ticket 2.5: Table Reskin

**Branch:** `admin-reskin/tables`

**Scope:**
- Row borders: 1px solid rgba(0,0,0,0.1)
- Header styling: subtle background or bold text
- Hover state: subtle tint
- Selected state: theme-alpha-04 background
- Striping: subtle alternation or remove
- Subsubsub links: proper active/hover states
- Pagination: button styling consistency
- Bulk actions: select and button alignment

**Files to modify:**
- `src/wp-admin/css/list-tables.css` (L404, L675)
- `src/wp-admin/css/common.css` (L430 - subsubsub, L464 - widefat)
- `src/wp-admin/css/forms.css` (L825 - form-table)

**Acceptance Criteria:**
- [ ] Row actions visible on hover
- [ ] Selected rows clearly indicated
- [ ] Pagination controls match button styles
- [ ] Table headers readable at all widths

**Estimated effort:** Medium (4-6 hours)

**Requirements doc:** [tables-reskin.md](./tables-reskin.md)

---

## Phase 3: Global Styling

### Ticket 3.1: Global Background

**Branch:** `admin-reskin/background`

**Scope:**
- Page background: #f0f0f0 (gray-100)
- Content surface: white
- Ensure cards "float" on gray background
- Test plugin compatibility

**Files to modify:**
- `src/wp-admin/css/common.css` (L10 - #wpcontent)

**Acceptance Criteria:**
- [ ] Background color applied globally
- [ ] White cards have proper contrast
- [ ] No regressions with existing plugins

**Estimated effort:** Small (1-2 hours)

**Requirements doc:** [background-and-frame.md](./background-and-frame.md)

---

### Ticket 3.2: Admin Menu Reskin (Optional)

**Branch:** `admin-reskin/admin-menu`

**Scope:**
- Menu item height: standardize to 40px or 48px
- Icon alignment: center in item
- Text size: 13px
- Active indicator: left border with theme color
- Hover states: subtle background change
- Submenu styling: consistent with main menu

**Files to modify:**
- `src/wp-admin/css/admin-menu.css` (L1+)
- `src/wp-admin/css/colors/_admin.scss` (menu colors)

**Acceptance Criteria:**
- [ ] Menu items evenly spaced
- [ ] Active state clearly visible
- [ ] All color schemes work correctly
- [ ] Collapsed menu state unchanged

**Estimated effort:** Medium (4-6 hours)

**Requirements doc:** [background-and-frame.md](./background-and-frame.md)

**Note:** This ticket may be deferred based on scope decisions.

---

### Ticket 3.3: Admin Bar Reskin (Optional)

**Branch:** `admin-reskin/admin-bar`

**Scope:**
- Height: 32px (maintain compatibility)
- Text size: 13px
- Hover states: consistent with menu
- Dropdown styling: match card system

**Files to modify:**
- `src/wp-includes/css/admin-bar.css` (L6+)

**Acceptance Criteria:**
- [ ] Admin bar height unchanged
- [ ] Dropdown menus styled consistently
- [ ] Frontend admin bar unaffected or improved

**Estimated effort:** Small (2-3 hours)

**Requirements doc:** [background-and-frame.md](./background-and-frame.md)

**Note:** This ticket may be deferred based on scope decisions.

---

## Phase 4: Typography

### Ticket 4.1: Typography Alignment

**Branch:** `admin-reskin/typography`

**Scope:**
- Body text: 13px/20px, weight 400
- Headings: appropriate scale with weight 500
- Ensure consistent line heights
- Review and align all font-size declarations

**Files to modify:**
- `src/wp-admin/css/common.css` (various)
- `src/wp-admin/css/forms.css`
- `src/wp-admin/css/dashboard.css`

**Acceptance Criteria:**
- [ ] Typography consistent across screens
- [ ] No text overflow or clipping
- [ ] Readable at 100% and 200% zoom

**Estimated effort:** Medium (4-6 hours)

---

## Phase 5: Polish and Testing

### Ticket 5.1: RTL Testing and Fixes

**Branch:** `admin-reskin/rtl-fixes`

**Scope:**
- Test all components in RTL mode
- Fix any directional issues
- Ensure focus rings appear correctly

**Acceptance Criteria:**
- [ ] All components render correctly in RTL
- [ ] No visual regressions

**Estimated effort:** Small (2-3 hours)

---

### Ticket 5.2: Color Scheme Testing

**Branch:** `admin-reskin/scheme-testing`

**Scope:**
- Test all 8 color schemes
- Fix any scheme-specific issues
- Ensure contrast requirements met

**Acceptance Criteria:**
- [ ] All schemes pass visual review
- [ ] Theme color usage correct in all contexts

**Estimated effort:** Small (2-3 hours)

---

### Ticket 5.3: Accessibility Audit

**Branch:** `admin-reskin/a11y-audit`

**Scope:**
- WCAG AA contrast verification
- Focus state visibility
- Screen reader testing

**Acceptance Criteria:**
- [ ] All text meets 4.5:1 contrast
- [ ] All UI elements meet 3:1 contrast
- [ ] Focus states visible in all contexts

**Estimated effort:** Medium (4-6 hours)

---

## Ticket Summary

| # | Ticket | Branch | Effort | Priority |
|---|--------|--------|--------|----------|
| 1.1 | Token Foundation | `admin-reskin/token-foundation` | S | P1 |
| 2.1 | Buttons | `admin-reskin/buttons` | M | P1 |
| 2.2 | Inputs | `admin-reskin/inputs` | M | P1 |
| 2.3 | Notices | `admin-reskin/notices` | S | P1 |
| 2.4 | Cards | `admin-reskin/cards` | M | P1 |
| 2.5 | Tables | `admin-reskin/tables` | M | P1 |
| 3.1 | Background | `admin-reskin/background` | S | P2 |
| 3.2 | Admin Menu | `admin-reskin/admin-menu` | M | P3 |
| 3.3 | Admin Bar | `admin-reskin/admin-bar` | S | P3 |
| 4.1 | Typography | `admin-reskin/typography` | M | P2 |
| 5.1 | RTL Fixes | `admin-reskin/rtl-fixes` | S | P2 |
| 5.2 | Scheme Testing | `admin-reskin/scheme-testing` | S | P2 |
| 5.3 | A11y Audit | `admin-reskin/a11y-audit` | M | P2 |

**Effort:** S = Small (1-3 hours), M = Medium (4-6 hours)

**Priority:** P1 = Must have, P2 = Should have, P3 = Nice to have (may defer)

---

## Git Commands Reference

### Initial Setup

```bash
# Create epic branch from trunk
git checkout trunk
git pull origin trunk
git checkout -b feature/admin-reskin-7.0
git push -u origin feature/admin-reskin-7.0
```

### Starting a Component Branch

```bash
# Create component branch from epic
git checkout feature/admin-reskin-7.0
git pull origin feature/admin-reskin-7.0
git checkout -b admin-reskin/buttons
```

### Merging Component to Epic

```bash
# After PR review and approval
git checkout feature/admin-reskin-7.0
git pull origin feature/admin-reskin-7.0
git merge admin-reskin/buttons
git push origin feature/admin-reskin-7.0
```

### Testing Full Reskin Locally

```bash
git checkout feature/admin-reskin-7.0
git pull origin feature/admin-reskin-7.0
npm run build
# Start local WordPress environment
```

### Final Merge to Trunk

```bash
# After all testing complete
git checkout trunk
git pull origin trunk
git merge feature/admin-reskin-7.0
git push origin trunk
```

---

## Review Checklist

Before merging any component branch:

- [ ] Code follows WordPress CSS coding standards
- [ ] No new CSS custom properties introduced
- [ ] Tested in modern and light color schemes
- [ ] Tested at 100% and 200% zoom
- [ ] RTL layout verified
- [ ] Focus states visible and accessible
- [ ] Before/after screenshots attached to PR
- [ ] Requirements doc referenced in PR description

