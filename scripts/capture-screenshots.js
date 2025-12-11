/**
 * Screenshot capture script for WP Admin UI Kit
 * 
 * This script captures high-resolution screenshots of individual UI components
 * for use in the requirements documentation.
 * 
 * Usage:
 *   node scripts/capture-screenshots.js
 * 
 * Prerequisites:
 *   - WordPress dev environment running at http://localhost:8889
 *   - npm install playwright (already installed)
 *   - npx playwright install chromium (if not already installed)
 */

const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

async function captureScreenshots() {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 1400, height: 1000 },
    deviceScaleFactor: 8  // 8x resolution for ultra-high-quality screenshots
  });
  const page = await context.newPage();
  
  const outputDir = path.join(__dirname, '..', 'requirenments', 'images');
  
  // Ensure output directory exists
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }
  
  // Login first
  console.log('Logging in...');
  await page.goto('http://localhost:8889/wp-login.php');
  await page.fill('#user_login', 'admin');
  await page.fill('#user_pass', 'password');
  await page.click('#wp-submit');
  await page.waitForURL('**/wp-admin/**');
  console.log('Logged in successfully');
  
  // Navigate to UI Kit
  console.log('Navigating to UI Kit...');
  await page.goto('http://localhost:8889/wp-admin/ui-kit.php');
  await page.waitForLoadState('networkidle');
  
  // Individual components to capture (selector -> filename)
  const components = [
    // Buttons - capture individual button elements
    { selector: '.button.button-primary:not([disabled])', name: 'button-primary', desc: 'Primary button' },
    { selector: '.button.button-secondary', name: 'button-secondary', desc: 'Secondary button' },
    { selector: '.button:not(.button-primary):not(.button-secondary):not(.button-link):not(.button-link-delete):not(.button-hero):not(.button-large):not(.button-small):not([disabled])', name: 'button-default', desc: 'Default button' },
    { selector: '.button.button-link', name: 'button-link', desc: 'Link button' },
    { selector: '.button.button-link-delete', name: 'button-link-delete', desc: 'Delete link button' },
    { selector: '.button.button-hero', name: 'button-hero', desc: 'Hero button' },
    { selector: '.button.button-large:not(.button-hero)', name: 'button-large', desc: 'Large button' },
    { selector: '.button.button-small', name: 'button-small', desc: 'Small button' },
    { selector: '.button[disabled]', name: 'button-disabled', desc: 'Disabled button' },
    
    // Inputs - capture individual input elements
    { selector: 'input.regular-text[type="text"]:not([disabled]):not([readonly])', name: 'input-text', desc: 'Text input' },
    { selector: 'input.large-text', name: 'input-text-large', desc: 'Large text input' },
    { selector: 'input.small-text[type="text"]', name: 'input-text-small', desc: 'Small text input' },
    { selector: 'input[disabled]', name: 'input-disabled', desc: 'Disabled input' },
    { selector: 'input[readonly]', name: 'input-readonly', desc: 'Readonly input' },
    { selector: 'textarea.large-text', name: 'input-textarea', desc: 'Textarea' },
    { selector: 'select:not([disabled])', name: 'input-select', desc: 'Select dropdown' },
    { selector: 'select[disabled]', name: 'input-select-disabled', desc: 'Disabled select' },
    { selector: 'input[type="checkbox"]', name: 'input-checkbox', desc: 'Checkbox' },
    { selector: 'input[type="radio"]', name: 'input-radio', desc: 'Radio button' },
    { selector: 'input[type="search"]', name: 'input-search', desc: 'Search input' },
    { selector: 'input[type="url"]', name: 'input-url', desc: 'URL input' },
    { selector: 'input[type="email"]', name: 'input-email', desc: 'Email input' },
    { selector: 'input[type="number"]', name: 'input-number', desc: 'Number input' },
    { selector: 'input[type="password"]', name: 'input-password', desc: 'Password input' },
    { selector: '.wp-pwd', name: 'input-password-toggle', desc: 'Password with toggle' },
    { selector: 'input[type="date"]', name: 'input-date', desc: 'Date input' },
    { selector: 'input[type="time"]', name: 'input-time', desc: 'Time input' },
    { selector: 'input[type="color"]', name: 'input-color', desc: 'Color input' },
    { selector: 'input[type="file"]', name: 'input-file', desc: 'File input' },
    { selector: 'input[type="range"]', name: 'input-range', desc: 'Range input' },
    
    // Notices  
    { selector: '.notice.notice-info.inline', name: 'notice-info', desc: 'Info notice' },
    { selector: '.notice.notice-success.inline', name: 'notice-success', desc: 'Success notice' },
    { selector: '.notice.notice-warning.inline', name: 'notice-warning', desc: 'Warning notice' },
    { selector: '.notice.notice-error.inline', name: 'notice-error', desc: 'Error notice' },
    { selector: '.notice.is-dismissible .notice-dismiss', name: 'notice-dismiss', desc: 'Notice dismiss button' },
    
    // Cards
    { selector: '#sample-postbox', name: 'card-postbox', desc: 'Postbox/metabox' },
    { selector: '#dashboard-widgets', name: 'card-dashboard', desc: 'Dashboard widget' },
    { selector: '.postbox-header', name: 'card-postbox-header', desc: 'Postbox header' },
    
    // Tables
    { selector: '.wp-list-table thead', name: 'table-header', desc: 'Table header' },
    { selector: '.wp-list-table tbody tr:first-child', name: 'table-row', desc: 'Table row' },
    { selector: '.form-table tr:first-child', name: 'table-form-row', desc: 'Form table row' },
    { selector: '.tablenav', name: 'table-nav', desc: 'Table navigation' },
    { selector: '.subsubsub', name: 'table-subsubsub', desc: 'Subsubsub filters' },
    { selector: '.tablenav-pages', name: 'table-pagination', desc: 'Table pagination' },
    { selector: '.bulkactions', name: 'table-bulk-actions', desc: 'Bulk actions' },
    { selector: '.column-cb.check-column', name: 'table-checkbox-column', desc: 'Checkbox column' },
    
    // Navigation
    { selector: '.nav-tab-wrapper', name: 'nav-tabs', desc: 'Navigation tabs' },
    { selector: '.nav-tab.nav-tab-active', name: 'nav-tab-active', desc: 'Active nav tab' },
    { selector: '.nav-tab:not(.nav-tab-active)', name: 'nav-tab', desc: 'Nav tab' },
    
    // Feedback
    { selector: '.spinner.is-active', name: 'feedback-spinner', desc: 'Spinner' },
    
    // Avatars
    { selector: '.avatar', name: 'media-avatar', desc: 'Avatar' },
  ];
  
  console.log(`\nCapturing ${components.length} individual components...`);
  
  for (const component of components) {
    try {
      const element = await page.$(component.selector);
      if (element) {
        await element.screenshot({ 
          path: path.join(outputDir, `${component.name}.png`),
          scale: 'device'  // Use device scale (4x) for maximum resolution
        });
        console.log(`✓ ${component.desc} -> ${component.name}.png`);
      } else {
        console.log(`✗ ${component.desc} - selector not found: ${component.selector}`);
      }
    } catch (e) {
      console.log(`✗ ${component.desc} - error: ${e.message}`);
    }
  }
  
  // Also capture full sections for reference
  console.log('\nCapturing full sections...');
  const sections = ['buttons', 'inputs', 'notices', 'tables', 'cards', 'navigation', 'feedback', 'typography'];
  
  for (const id of sections) {
    try {
      await page.goto(`http://localhost:8889/wp-admin/ui-kit.php#${id}`);
      await page.waitForTimeout(300);
      const element = await page.$(`#${id}`);
      if (element) {
        await element.screenshot({ 
          path: path.join(outputDir, `section-${id}.png`),
          scale: 'device'  // Use device scale (4x) for maximum resolution
        });
        console.log(`✓ Section: ${id}`);
      }
    } catch (e) {
      console.log(`✗ Section ${id}: ${e.message}`);
    }
  }
  
  await browser.close();
  console.log('\nDone! Screenshots saved to requirenments/images/');
}

captureScreenshots().catch(console.error);

