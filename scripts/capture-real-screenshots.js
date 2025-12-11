/**
 * Capture screenshots of UI components from real WP Admin pages
 * Run with: node scripts/capture-real-screenshots.js
 */

const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const ADMIN_URL = 'http://localhost:8889/wp-admin';
const OUTPUT_DIR = path.join(__dirname, '../requirenments/images/real');

// Create output directory
if (!fs.existsSync(OUTPUT_DIR)) {
  fs.mkdirSync(OUTPUT_DIR, { recursive: true });
}

// Helper to safely capture element screenshot
async function captureElement(page, selector, filename, description) {
  try {
    const element = await page.$(selector);
    if (element) {
      const isVisible = await element.isVisible().catch(() => true);
      if (isVisible) {
        await element.screenshot({ 
          path: path.join(OUTPUT_DIR, filename), 
          scale: 'device',
          timeout: 5000
        });
        console.log(`✓ ${description}`);
        return true;
      } else {
        console.log(`⊘ ${description} (not visible)`);
      }
    } else {
      console.log(`⊘ ${description} (not found)`);
    }
  } catch (err) {
    console.log(`✗ ${description} (error: ${err.message})`);
  }
  return false;
}

async function run() {
  const browser = await chromium.launch();
  const context = await browser.newContext({
    viewport: { width: 1400, height: 1000 },
    deviceScaleFactor: 8  // 8x for retina
  });
  const page = await context.newPage();

  // Login
  console.log('Logging in...');
  await page.goto('http://localhost:8889/wp-login.php');
  await page.fill('#user_login', 'admin');
  await page.fill('#user_pass', 'password');
  await page.click('#wp-submit');
  await page.waitForURL('**/wp-admin/**');
  console.log('Logged in successfully\n');

  // ============================================================
  // BUTTONS
  // ============================================================
  console.log('=== Capturing Buttons ===');

  // Settings page - Primary button
  await page.goto(`${ADMIN_URL}/options-general.php`);
  await page.waitForLoadState('networkidle');
  await captureElement(page, '#submit', 'button-primary-settings.png', 'Primary button (Settings page)');

  // Plugins page - Secondary buttons
  await page.goto(`${ADMIN_URL}/plugins.php`);
  await page.waitForLoadState('networkidle');
  await captureElement(page, '.bulkactions .button.action', 'button-secondary-bulk.png', 'Secondary button (Bulk actions)');

  // Dashboard - Save Draft button
  await page.goto(`${ADMIN_URL}/`);
  await page.waitForLoadState('networkidle');
  await captureElement(page, '#quick-press #save-post', 'button-primary-quickdraft.png', 'Primary button (Quick Draft)');

  // ============================================================
  // INPUTS
  // ============================================================
  console.log('\n=== Capturing Inputs ===');

  // Settings General - Text inputs
  await page.goto(`${ADMIN_URL}/options-general.php`);
  await page.waitForLoadState('networkidle');
  await captureElement(page, '#blogname', 'input-text-sitetitle.png', 'Text input (Site Title)');
  await captureElement(page, '#siteurl', 'input-url-siteurl.png', 'URL input (Site URL)');
  await captureElement(page, '#new_admin_email', 'input-email-admin.png', 'Email input (Admin Email)');
  await captureElement(page, '#timezone_string', 'input-select-timezone.png', 'Select (Timezone)');

  // Settings Reading - Number inputs
  await page.goto(`${ADMIN_URL}/options-reading.php`);
  await page.waitForLoadState('networkidle');
  await captureElement(page, '#posts_per_page', 'input-number-posts.png', 'Number input (Posts per page)');

  // Settings Discussion - Checkboxes and Textarea
  await page.goto(`${ADMIN_URL}/options-discussion.php`);
  await page.waitForLoadState('networkidle');
  await captureElement(page, 'input[type="checkbox"]', 'input-checkbox-discussion.png', 'Checkbox (Discussion)');
  await captureElement(page, '#moderation_keys', 'input-textarea-moderation.png', 'Textarea (Moderation keys)');

  // User Profile - Password field
  await page.goto(`${ADMIN_URL}/profile.php`);
  await page.waitForLoadState('networkidle');
  const generatePassword = await page.$('.generate-pass');
  if (generatePassword) {
    try {
      await generatePassword.click();
      await page.waitForTimeout(500);
      await captureElement(page, '.wp-pwd', 'input-password-profile.png', 'Password input with toggle (Profile)');
    } catch (e) {
      console.log(`✗ Password input (error: ${e.message})`);
    }
  }

  // Search box on Posts
  await page.goto(`${ADMIN_URL}/edit.php`);
  await page.waitForLoadState('networkidle');
  await captureElement(page, '.search-box', 'input-search-posts.png', 'Search box (Posts)');

  // Radio buttons - Settings Reading
  await page.goto(`${ADMIN_URL}/options-reading.php`);
  await page.waitForLoadState('networkidle');
  await captureElement(page, 'input[type="radio"]', 'input-radio-reading.png', 'Radio button (Reading)');

  // ============================================================
  // NOTICES
  // ============================================================
  console.log('\n=== Capturing Notices ===');

  // Save settings to trigger a success notice
  await page.goto(`${ADMIN_URL}/options-general.php`);
  await page.waitForLoadState('networkidle');
  await page.click('#submit');
  await page.waitForLoadState('networkidle');
  await captureElement(page, '.notice-success, .updated', 'notice-success-settings.png', 'Success notice (Settings saved)');

  // ============================================================
  // CARDS / WIDGETS
  // ============================================================
  console.log('\n=== Capturing Cards ===');

  // Dashboard widgets
  await page.goto(`${ADMIN_URL}/`);
  await page.waitForLoadState('networkidle');
  await captureElement(page, '#dashboard_quick_press', 'card-quickdraft.png', 'Quick Draft widget');
  await captureElement(page, '#dashboard_right_now', 'card-ataglance.png', 'At a Glance widget');
  await captureElement(page, '#dashboard_activity', 'card-activity.png', 'Activity widget');
  await captureElement(page, '#welcome-panel', 'card-welcome.png', 'Welcome panel');

  // Plugin card (requires network for search results)
  await page.goto(`${ADMIN_URL}/plugin-install.php`);
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(2000); // Wait for plugin cards to load
  await captureElement(page, '.plugin-card', 'card-plugin.png', 'Plugin card');

  // Theme card
  await page.goto(`${ADMIN_URL}/themes.php`);
  await page.waitForLoadState('networkidle');
  await captureElement(page, '.theme', 'card-theme.png', 'Theme card');

  // ============================================================
  // TABLES
  // ============================================================
  console.log('\n=== Capturing Tables ===');

  // Posts list table
  await page.goto(`${ADMIN_URL}/edit.php`);
  await page.waitForLoadState('networkidle');
  await captureElement(page, '.wp-list-table', 'table-posts-list.png', 'Posts list table');
  await captureElement(page, '.wp-list-table thead', 'table-header-posts.png', 'Table header (Posts)');
  await captureElement(page, '.wp-list-table tbody tr', 'table-row-posts.png', 'Table row (Posts)');
  await captureElement(page, '.tablenav.top', 'table-nav-posts.png', 'Table navigation (Posts)');
  await captureElement(page, '.subsubsub', 'table-subsubsub-posts.png', 'Subsubsub filters (Posts)');
  await captureElement(page, '.tablenav-pages', 'table-pagination-posts.png', 'Pagination (Posts)');
  await captureElement(page, '.bulkactions', 'table-bulk-actions-posts.png', 'Bulk actions (Posts)');

  // Form table on settings
  await page.goto(`${ADMIN_URL}/options-general.php`);
  await page.waitForLoadState('networkidle');
  await captureElement(page, '.form-table', 'table-form-settings.png', 'Form table (Settings)');
  await captureElement(page, '.form-table tr', 'table-form-row-settings.png', 'Form table row (Settings)');

  // Users list
  await page.goto(`${ADMIN_URL}/users.php`);
  await page.waitForLoadState('networkidle');
  await captureElement(page, '.wp-list-table', 'table-users-list.png', 'Users list table');

  // Plugins list
  await page.goto(`${ADMIN_URL}/plugins.php`);
  await page.waitForLoadState('networkidle');
  await captureElement(page, '.wp-list-table', 'table-plugins-list.png', 'Plugins list table');

  // ============================================================
  // NAVIGATION
  // ============================================================
  console.log('\n=== Capturing Navigation ===');

  // Filter tabs on plugin install
  await page.goto(`${ADMIN_URL}/plugin-install.php`);
  await page.waitForLoadState('networkidle');
  await captureElement(page, '.wp-filter', 'nav-wp-filter.png', 'WP Filter bar (Plugin Install)');
  await captureElement(page, '.filter-links', 'nav-filter-links.png', 'Filter links (Plugin Install)');

  // View switcher on Media
  await page.goto(`${ADMIN_URL}/upload.php`);
  await page.waitForLoadState('networkidle');
  await captureElement(page, '.view-switch', 'nav-view-switcher.png', 'View switcher (Media)');

  // ============================================================
  // FEEDBACK / SPINNERS
  // ============================================================
  console.log('\n=== Capturing Feedback ===');

  // Site Health
  await page.goto(`${ADMIN_URL}/site-health.php`);
  await page.waitForLoadState('networkidle');
  await captureElement(page, '.site-health-progress', 'feedback-site-health.png', 'Site Health progress');
  await captureElement(page, '.site-status-all-clear, .site-health-issues', 'feedback-site-health-status.png', 'Site Health status');

  // ============================================================
  // MISC
  // ============================================================
  console.log('\n=== Capturing Miscellaneous ===');

  // Screen Options
  await page.goto(`${ADMIN_URL}/edit.php`);
  await page.waitForLoadState('networkidle');
  const screenOptionsTab = await page.$('#show-settings-link');
  if (screenOptionsTab) {
    try {
      await screenOptionsTab.click();
      await page.waitForTimeout(300);
      await captureElement(page, '#screen-options-wrap', 'misc-screen-options.png', 'Screen Options panel');
    } catch (e) {
      console.log(`✗ Screen Options (error: ${e.message})`);
    }
  }

  // Help Tab
  const helpTab = await page.$('#contextual-help-link');
  if (helpTab) {
    try {
      await helpTab.click();
      await page.waitForTimeout(300);
      await captureElement(page, '#contextual-help-wrap', 'misc-help-panel.png', 'Help panel');
    } catch (e) {
      console.log(`✗ Help panel (error: ${e.message})`);
    }
  }

  // Avatar from Users
  await page.goto(`${ADMIN_URL}/users.php`);
  await page.waitForLoadState('networkidle');
  await captureElement(page, '.avatar', 'misc-avatar.png', 'Avatar (Users)');

  // Admin menu
  await page.goto(`${ADMIN_URL}/`);
  await page.waitForLoadState('networkidle');
  await captureElement(page, '#adminmenu', 'misc-admin-menu.png', 'Admin menu');
  await captureElement(page, '#wpadminbar', 'misc-admin-bar.png', 'Admin bar');

  console.log('\n=== Done! ===');
  console.log(`Screenshots saved to: ${OUTPUT_DIR}`);

  await browser.close();
}

run().catch(console.error);
