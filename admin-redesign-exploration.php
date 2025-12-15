<?php
/**
 * Plugin Name: Admin Redesign Exploration
 * Description: An exploratory plugin for the WordPress 7.0 admin visual refresh. Replaces core stylesheets with forked versions for iterative design work.
 * Version: 0.1.0
 * Author: Fabian Kägy
 * Author URI: https://fabian-kaegy.com
 * Text Domain: admin-redesign-exploration
 * Requires PHP: 8.0
 * Requires at least: 6.7
 * License: GPL-2.0-or-later
 *
 * @package Admin_Redesign
 */

declare( strict_types=1 );

// Plugin constants.
define( 'ADMIN_REDESIGN_VERSION', '0.1.0' );
define( 'ADMIN_REDESIGN_URL', plugin_dir_url( __FILE__ ) );
define( 'ADMIN_REDESIGN_PATH', plugin_dir_path( __FILE__ ) );
define( 'ADMIN_REDESIGN_INC', ADMIN_REDESIGN_PATH . 'includes/' );

// Load style overrides to replace core stylesheets with forked versions.
// This uses the Gutenberg pattern of hooking into wp_default_styles.
require_once ADMIN_REDESIGN_INC . 'style-overrides.php';
