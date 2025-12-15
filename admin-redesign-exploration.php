<?php
/**
 * Plugin Name: Admin Redesign Exploration
 * Description: An exploratory plugin that applies some CSS tweaks to the WP Admin based on the Admin Redesign design project.
 * Version: 0.1.0
 * Author: Fabian Kägy
 * Author URI: https://fabian-kaegy.com
 * Text Domain: admin-redesign-exploration
 * Requires PHP: 8.0
 * Requires at least: 6.7
 * License: GPL-2.0-or-later
 *
 * @package ADMIN_REDESIGN
 */

// Useful global constants.
define( 'ADMIN_REDESIGN_VERSION', '0.1.0' );
define( 'ADMIN_REDESIGN_URL', plugin_dir_url( __FILE__ ) );
define( 'ADMIN_REDESIGN_PATH', plugin_dir_path( __FILE__ ) );
define( 'ADMIN_REDESIGN_INC', ADMIN_REDESIGN_PATH . 'includes/' );
define( 'ADMIN_REDESIGN_DIST_URL', ADMIN_REDESIGN_URL . 'dist/' );
define( 'ADMIN_REDESIGN_DIST_PATH', ADMIN_REDESIGN_PATH . 'dist/' );
define( 'ADMIN_REDESIGN_BLOCKS_PATH', ADMIN_REDESIGN_DIST_PATH . 'blocks/' );

$is_local_env = in_array( wp_get_environment_type(), [ 'local', 'development' ], true );
$is_local_url = strpos( home_url(), '.test' ) || strpos( home_url(), '.local' );
$is_local     = $is_local_env || $is_local_url;

if ( $is_local && file_exists( __DIR__ . '/dist/fast-refresh.php' ) ) {
	require_once __DIR__ . '/dist/fast-refresh.php';
	TenUpToolkit\set_dist_url_path( basename( __DIR__ ), ADMIN_REDESIGN_DIST_URL, ADMIN_REDESIGN_DIST_PATH );
}

// Require Composer autoloader if it exists.
if ( file_exists( ADMIN_REDESIGN_PATH . 'vendor/autoload.php' ) ) {
	require_once ADMIN_REDESIGN_PATH . 'vendor/autoload.php';
}

// Load style overrides to replace core stylesheets with forked versions.
// This uses the Gutenberg pattern of hooking into wp_default_styles.
require_once ADMIN_REDESIGN_INC . 'style-overrides.php';

add_filter( 'admin_enqueue_scripts', 'admin_redesign_enqueue_scripts' );

/**
 * Enqueue the admin redesign styles.
 */
function admin_redesign_enqueue_scripts() {
	$style_asset_file = ADMIN_REDESIGN_DIST_PATH . 'css/admin-redesign.asset.php';
	$style_asset      = file_exists( $style_asset_file ) ? require $style_asset_file : [];

	wp_enqueue_style(
		'admin-redesign',
		ADMIN_REDESIGN_DIST_URL . 'css/admin-redesign.css',
		$style_asset['dependencies'] ?? [],
		$style_asset['version'] ?? ADMIN_REDESIGN_VERSION
	);

	$script_asset_file = ADMIN_REDESIGN_DIST_PATH . 'js/admin-enhancements.asset.php';
	$script_asset      = file_exists( $script_asset_file ) ? require $script_asset_file : [];

	wp_enqueue_script(
		'admin-redesign',
		ADMIN_REDESIGN_DIST_URL . 'js/admin-enhancements.js',
		$script_asset['dependencies'] ?? [],
		$script_asset['version'] ?? ADMIN_REDESIGN_VERSION,
		[
			'defer' => true,
		]
	);
}

add_action( 'admin_head', 'admin_redesign_admin_head' );

/**
 * Add custom admin styles to the admin head.
 */
function admin_redesign_admin_head() {
	?>
	<script id="admin-redesign-initial-width">
		// Set the initial width of the sidebar
	const initialWidth = localStorage.getItem('admin-redesign-sidebar-width') || 300;
	document.documentElement.style.setProperty('--admin-redesign-sidebar-width', `${initialWidth}px`);
	</script>
	<?php
}


// remove the auto-fold class from the admin body classes
add_filter( 'admin_body_class', 'admin_redesign_remove_auto_fold_class' );

/**
 * Remove the auto-fold class from the admin body classes.
 *
 * @param string $classes The current body classes.
 *
 * @return array
 */
function admin_redesign_remove_auto_fold_class( $classes ) {
	$classes_array = explode( ' ', $classes );

	$auto_fold_key = array_search( 'auto-fold', $classes_array, true );

	if ( false !== $auto_fold_key ) {
		unset( $classes_array[ $auto_fold_key ] );
	}

	return join( ' ', $classes_array );
}