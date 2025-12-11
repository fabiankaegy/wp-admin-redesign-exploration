/**
 * Capture screenshots of components from Gutenberg Storybook
 * https://wordpress.github.io/gutenberg/
 * 
 * Run with: node scripts/capture-storybook-screenshots.js
 */

const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const STORYBOOK_URL = 'https://wordpress.github.io/gutenberg';
const OUTPUT_DIR = path.join(__dirname, '../requirenments/images/storybook');

// Create output directory
if (!fs.existsSync(OUTPUT_DIR)) {
  fs.mkdirSync(OUTPUT_DIR, { recursive: true });
}

// Component stories to capture
const STORIES = [
  // Buttons
  { path: 'components-button--default', name: 'button-default', desc: 'Button Default' },
  { path: 'components-button--primary', name: 'button-primary', desc: 'Button Primary' },
  { path: 'components-button--secondary', name: 'button-secondary', desc: 'Button Secondary' },
  { path: 'components-button--tertiary', name: 'button-tertiary', desc: 'Button Tertiary' },
  { path: 'components-button--link', name: 'button-link', desc: 'Button Link' },
  { path: 'components-button--destructive', name: 'button-destructive', desc: 'Button Destructive' },
  { path: 'components-button--small', name: 'button-small', desc: 'Button Small' },
  { path: 'components-button--icon', name: 'button-icon', desc: 'Button Icon' },
  
  // Text Inputs
  { path: 'components-textcontrol--default', name: 'input-text', desc: 'TextControl' },
  { path: 'components-textareacontrol--default', name: 'input-textarea', desc: 'TextareaControl' },
  { path: 'components-numbercontrol--default', name: 'input-number', desc: 'NumberControl' },
  { path: 'components-searchcontrol--default', name: 'input-search', desc: 'SearchControl' },
  
  // Select and Options
  { path: 'components-selectcontrol--default', name: 'input-select', desc: 'SelectControl' },
  { path: 'components-comboboxcontrol--default', name: 'input-combobox', desc: 'ComboboxControl' },
  { path: 'components-customselectcontrol--default', name: 'input-custom-select', desc: 'CustomSelectControl' },
  
  // Checkboxes and Toggles
  { path: 'components-checkboxcontrol--default', name: 'input-checkbox', desc: 'CheckboxControl' },
  { path: 'components-togglecontrol--default', name: 'input-toggle', desc: 'ToggleControl' },
  { path: 'components-radiocontrol--default', name: 'input-radio', desc: 'RadioControl' },
  
  // Notices
  { path: 'components-notice--default', name: 'notice-default', desc: 'Notice Default' },
  { path: 'components-notice--with-actions', name: 'notice-actions', desc: 'Notice with Actions' },
  { path: 'components-snackbar--default', name: 'snackbar', desc: 'Snackbar' },
  
  // Cards and Surfaces
  { path: 'components-card--default', name: 'card-default', desc: 'Card Default' },
  { path: 'components-card--with-header-and-footer', name: 'card-full', desc: 'Card with Header/Footer' },
  { path: 'components-surface--default', name: 'surface', desc: 'Surface' },
  { path: 'components-panel--default', name: 'panel', desc: 'Panel' },
  
  // Navigation
  { path: 'components-tabpanel--default', name: 'nav-tabs', desc: 'TabPanel' },
  { path: 'components-navigation--default', name: 'nav-navigation', desc: 'Navigation' },
  { path: 'components-navigator-navigator--default', name: 'nav-navigator', desc: 'Navigator' },
  
  // Feedback
  { path: 'components-spinner--default', name: 'feedback-spinner', desc: 'Spinner' },
  { path: 'components-progressbar--default', name: 'feedback-progressbar', desc: 'ProgressBar' },
  
  // Typography
  { path: 'components-heading--default', name: 'type-heading', desc: 'Heading' },
  { path: 'components-text--default', name: 'type-text', desc: 'Text' },
  { path: 'components-truncate--default', name: 'type-truncate', desc: 'Truncate' },
  
  // Layout
  { path: 'components-flex--default', name: 'layout-flex', desc: 'Flex' },
  { path: 'components-hstack--default', name: 'layout-hstack', desc: 'HStack' },
  { path: 'components-vstack--default', name: 'layout-vstack', desc: 'VStack' },
  { path: 'components-spacer--default', name: 'layout-spacer', desc: 'Spacer' },
  
  // Modal and Dialogs
  { path: 'components-modal--default', name: 'modal', desc: 'Modal' },
  { path: 'components-confirmdialog--default', name: 'dialog-confirm', desc: 'ConfirmDialog' },
  { path: 'components-popover--default', name: 'popover', desc: 'Popover' },
  { path: 'components-dropdown--default', name: 'dropdown', desc: 'Dropdown' },
  { path: 'components-dropdownmenu--default', name: 'dropdown-menu', desc: 'DropdownMenu' },
  { path: 'components-tooltip--default', name: 'tooltip', desc: 'Tooltip' },
  
  // Form Components
  { path: 'components-formtokenfield--default', name: 'form-tokenfield', desc: 'FormTokenField' },
  { path: 'components-datepicker--default', name: 'form-datepicker', desc: 'DatePicker' },
  { path: 'components-timepicker--default', name: 'form-timepicker', desc: 'TimePicker' },
  { path: 'components-colorpicker--default', name: 'form-colorpicker', desc: 'ColorPicker' },
  { path: 'components-colorpalette--default', name: 'form-colorpalette', desc: 'ColorPalette' },
  
  // Icons
  { path: 'icons-library--library', name: 'icons-library', desc: 'Icon Library' },
];

async function captureStory(page, storyPath, filename, description) {
  try {
    // Navigate to isolated story view (iframe)
    const url = `${STORYBOOK_URL}/iframe.html?id=${storyPath}&viewMode=story`;
    await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
    
    // Wait for component to render
    await page.waitForTimeout(500);
    
    // Get the storybook root
    const root = await page.$('#storybook-root');
    if (root) {
      await root.screenshot({ 
        path: path.join(OUTPUT_DIR, `${filename}.png`),
        scale: 'device'
      });
      console.log(`✓ ${description}`);
      return true;
    } else {
      // Fall back to full page
      await page.screenshot({ 
        path: path.join(OUTPUT_DIR, `${filename}.png`),
        scale: 'device'
      });
      console.log(`✓ ${description} (full page)`);
      return true;
    }
  } catch (err) {
    console.log(`✗ ${description} (${err.message})`);
    return false;
  }
}

async function run() {
  const browser = await chromium.launch();
  const context = await browser.newContext({
    viewport: { width: 800, height: 600 },
    deviceScaleFactor: 4  // 4x for retina
  });
  const page = await context.newPage();

  console.log('Capturing Gutenberg Storybook components...\n');

  let captured = 0;
  let failed = 0;

  for (const story of STORIES) {
    const success = await captureStory(page, story.path, story.name, story.desc);
    if (success) captured++;
    else failed++;
  }

  console.log(`\n=== Done! ===`);
  console.log(`Captured: ${captured}`);
  console.log(`Failed: ${failed}`);
  console.log(`Output: ${OUTPUT_DIR}`);

  await browser.close();
}

run().catch(console.error);

