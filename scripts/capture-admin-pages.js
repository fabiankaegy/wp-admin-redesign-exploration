/**
 * Capture full-page screenshots of all WP Admin pages
 * 
 * This script navigates to every top-level admin menu page and every settings
 * sub-page, capturing full-page screenshots for visual comparison.
 * 
 * Screenshots are automatically suffixed with the current git branch name from
 * the wordpress-develop repo, making it easy to compare across branches.
 * 
 * Usage:
 *   node scripts/capture-admin-pages.js
 *   node scripts/capture-admin-pages.js --output=./my-screenshots
 *   node scripts/capture-admin-pages.js --url=http://localhost:8888
 *   node scripts/capture-admin-pages.js --wp-dev-path=/path/to/wordpress-develop
 *   node scripts/capture-admin-pages.js --no-branch-suffix
 * 
 * Prerequisites:
 *   - WordPress dev environment running (default: http://localhost:8889)
 *   - npm install playwright
 *   - npx playwright install chromium
 */

const { chromium } = require('playwright');
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// Parse CLI arguments
const args = process.argv.slice(2);
const getArg = (name, defaultValue) => {
  const arg = args.find(a => a.startsWith(`--${name}=`));
  return arg ? arg.split('=')[1] : defaultValue;
};
const hasFlag = (name) => args.includes(`--${name}`);

const ADMIN_URL = getArg('url', 'http://localhost:8889') + '/wp-admin';
const OUTPUT_DIR = getArg('output', path.join(__dirname, '../requirenments/images/admin-pages'));
const USERNAME = getArg('user', 'admin');
const PASSWORD = getArg('pass', 'password');
const WP_DEV_PATH = getArg('wp-dev-path', path.join(__dirname, '../../wordpress-develop'));
const NO_BRANCH_SUFFIX = hasFlag('no-branch-suffix');

/**
 * Get the current git branch name from a repository
 * @param {string} repoPath - Path to the git repository
 * @returns {string} Branch name sanitized for use in filenames
 */
function getGitBranch(repoPath) {
  try {
    const branch = execSync('git rev-parse --abbrev-ref HEAD', {
      cwd: repoPath,
      encoding: 'utf-8',
      stdio: ['pipe', 'pipe', 'pipe']
    }).trim();
    
    // Sanitize branch name for use in filenames
    // Replace slashes and other problematic characters with dashes
    return branch.replace(/[\/\\:*?"<>|]/g, '-');
  } catch (err) {
    console.warn(`Warning: Could not detect git branch from ${repoPath}`);
    console.warn(`  ${err.message}`);
    return null;
  }
}

// Detect branch name
let BRANCH_SUFFIX = '';
if (!NO_BRANCH_SUFFIX) {
  const branch = getGitBranch(WP_DEV_PATH);
  if (branch) {
    BRANCH_SUFFIX = `-${branch}`;
  }
}

// Top-level admin pages
const TOP_LEVEL_PAGES = [
  { path: 'index.php', name: 'dashboard', desc: 'Dashboard' },
  { path: 'edit.php', name: 'posts', desc: 'Posts' },
  { path: 'post-new.php', name: 'post-new', desc: 'Add New Post' },
  { path: 'edit-tags.php?taxonomy=category', name: 'categories', desc: 'Categories' },
  { path: 'edit-tags.php?taxonomy=post_tag', name: 'tags', desc: 'Tags' },
  { path: 'upload.php', name: 'media', desc: 'Media Library' },
  { path: 'media-new.php', name: 'media-new', desc: 'Add New Media' },
  { path: 'edit.php?post_type=page', name: 'pages', desc: 'Pages' },
  { path: 'post-new.php?post_type=page', name: 'page-new', desc: 'Add New Page' },
  { path: 'edit-comments.php', name: 'comments', desc: 'Comments' },
  { path: 'themes.php', name: 'themes', desc: 'Themes' },
  { path: 'customize.php', name: 'customize', desc: 'Customize', skip: true }, // Opens in customizer, skip for now
  { path: 'widgets.php', name: 'widgets', desc: 'Widgets' },
  { path: 'nav-menus.php', name: 'menus', desc: 'Menus' },
  { path: 'theme-editor.php', name: 'theme-editor', desc: 'Theme Editor', skip: true }, // May not exist
  { path: 'plugins.php', name: 'plugins', desc: 'Plugins' },
  { path: 'plugin-install.php', name: 'plugin-install', desc: 'Add New Plugin' },
  { path: 'plugin-editor.php', name: 'plugin-editor', desc: 'Plugin Editor', skip: true }, // May not exist
  { path: 'users.php', name: 'users', desc: 'Users' },
  { path: 'user-new.php', name: 'user-new', desc: 'Add New User' },
  { path: 'profile.php', name: 'profile', desc: 'Your Profile' },
  { path: 'tools.php', name: 'tools', desc: 'Tools' },
  { path: 'import.php', name: 'import', desc: 'Import' },
  { path: 'export.php', name: 'export', desc: 'Export' },
  { path: 'site-health.php', name: 'site-health', desc: 'Site Health' },
  { path: 'export-personal-data.php', name: 'export-personal-data', desc: 'Export Personal Data' },
  { path: 'erase-personal-data.php', name: 'erase-personal-data', desc: 'Erase Personal Data' },
  { path: 'options-general.php', name: 'settings-general', desc: 'Settings - General' },
  { path: 'update-core.php', name: 'updates', desc: 'Updates' },
];

// All Settings sub-pages
const SETTINGS_PAGES = [
  { path: 'options-general.php', name: 'settings-general', desc: 'Settings - General' },
  { path: 'options-writing.php', name: 'settings-writing', desc: 'Settings - Writing' },
  { path: 'options-reading.php', name: 'settings-reading', desc: 'Settings - Reading' },
  { path: 'options-discussion.php', name: 'settings-discussion', desc: 'Settings - Discussion' },
  { path: 'options-media.php', name: 'settings-media', desc: 'Settings - Media' },
  { path: 'options-permalink.php', name: 'settings-permalinks', desc: 'Settings - Permalinks' },
  { path: 'options-privacy.php', name: 'settings-privacy', desc: 'Settings - Privacy' },
];

// Additional admin pages that are commonly used
const ADDITIONAL_PAGES = [
  { path: 'ui-kit.php', name: 'ui-kit', desc: 'UI Kit (if exists)', optional: true },
  { path: 'site-health.php?tab=debug', name: 'site-health-debug', desc: 'Site Health - Debug Info' },
  { path: 'about.php', name: 'about', desc: 'About WordPress' },
  { path: 'credits.php', name: 'credits', desc: 'Credits' },
  { path: 'freedoms.php', name: 'freedoms', desc: 'Freedoms' },
  { path: 'privacy.php', name: 'privacy-policy', desc: 'Privacy Policy' },
  { path: 'contribute.php', name: 'contribute', desc: 'Get Involved' },
];

// Combine all pages, removing duplicates by path
const ALL_PAGES = [...TOP_LEVEL_PAGES, ...SETTINGS_PAGES, ...ADDITIONAL_PAGES]
  .filter(page => !page.skip)
  .reduce((acc, page) => {
    if (!acc.find(p => p.path === page.path)) {
      acc.push(page);
    }
    return acc;
  }, []);

// Create output directory
if (!fs.existsSync(OUTPUT_DIR)) {
  fs.mkdirSync(OUTPUT_DIR, { recursive: true });
}

async function captureFullPage(page, adminPath, filename, description, optional = false) {
  const url = `${ADMIN_URL}/${adminPath}`;
  const fullFilename = `${filename}${BRANCH_SUFFIX}.png`;
  
  try {
    const response = await page.goto(url, { 
      waitUntil: 'networkidle',
      timeout: 30000 
    });
    
    // Check if page exists
    if (response && response.status() === 404) {
      if (optional) {
        console.log(`⊘ ${description} (not available)`);
      } else {
        console.log(`✗ ${description} (404)`);
      }
      return false;
    }
    
    // Wait for any dynamic content
    await page.waitForTimeout(500);
    
    // Capture full page screenshot
    await page.screenshot({ 
      path: path.join(OUTPUT_DIR, fullFilename),
      fullPage: true,
      scale: 'device'
    });
    
    console.log(`✓ ${description} -> ${fullFilename}`);
    return true;
    
  } catch (err) {
    if (optional) {
      console.log(`⊘ ${description} (${err.message})`);
    } else {
      console.log(`✗ ${description} (${err.message})`);
    }
    return false;
  }
}

async function run() {
  console.log('WP Admin Full-Page Screenshot Capture');
  console.log('=====================================');
  console.log(`URL: ${ADMIN_URL}`);
  console.log(`Output: ${OUTPUT_DIR}`);
  console.log(`Pages to capture: ${ALL_PAGES.length}`);
  if (BRANCH_SUFFIX) {
    console.log(`Branch: ${BRANCH_SUFFIX.substring(1)} (from ${WP_DEV_PATH})`);
    console.log(`Filename pattern: {page}${BRANCH_SUFFIX}.png`);
  } else {
    console.log(`Branch suffix: disabled`);
  }
  console.log('');
  
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 1400, height: 900 },
    deviceScaleFactor: 2  // 2x for retina quality
  });
  const page = await context.newPage();

  // Login
  console.log('Logging in...');
  try {
    await page.goto(ADMIN_URL.replace('/wp-admin', '') + '/wp-login.php');
    await page.fill('#user_login', USERNAME);
    await page.fill('#user_pass', PASSWORD);
    await page.click('#wp-submit');
    await page.waitForURL('**/wp-admin/**', { timeout: 10000 });
    console.log('Logged in successfully\n');
  } catch (err) {
    console.error(`Failed to login: ${err.message}`);
    console.error('Make sure WordPress is running and credentials are correct.');
    await browser.close();
    process.exit(1);
  }

  let captured = 0;
  let failed = 0;
  let skipped = 0;

  // Capture all pages
  console.log('=== Capturing Admin Pages ===\n');
  
  for (const pageInfo of ALL_PAGES) {
    const success = await captureFullPage(
      page, 
      pageInfo.path, 
      pageInfo.name, 
      pageInfo.desc,
      pageInfo.optional
    );
    
    if (success) {
      captured++;
    } else if (pageInfo.optional) {
      skipped++;
    } else {
      failed++;
    }
  }

  console.log('\n=== Summary ===');
  console.log(`Captured: ${captured}`);
  console.log(`Failed: ${failed}`);
  console.log(`Skipped: ${skipped}`);
  console.log(`\nScreenshots saved to: ${OUTPUT_DIR}`);

  await browser.close();
}

run().catch(err => {
  console.error('Script failed:', err);
  process.exit(1);
});

