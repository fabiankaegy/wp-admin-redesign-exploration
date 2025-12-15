<?php
/**
 * Style Overrides for Admin Redesign
 *
 * Uses the Gutenberg pattern: hook into wp_default_styles at priority 15
 * (after core's priority 10) and deregister/re-register styles with
 * plugin URLs.
 *
 * @package Admin_Redesign
 */

declare( strict_types=1 );

/**
 * Registers a style by first deregistering any existing style with the same handle.
 * This is the same pattern used by Gutenberg.
 *
 * @param WP_Styles        $styles WP_Styles instance.
 * @param string           $handle Name of the stylesheet.
 * @param string           $src    Full URL of the stylesheet.
 * @param array            $deps   Optional. Dependencies. Default empty array.
 * @param string|bool|null $ver    Optional. Version string. Default false (WP version).
 * @param string           $media  Optional. Media type. Default 'all'.
 */
function admin_redesign_override_style( $styles, $handle, $src, $deps = array(), $ver = false, $media = 'all' ) {
	$style = $styles->query( $handle, 'registered' );
	if ( $style ) {
		$styles->remove( $handle );
	}
	$styles->add( $handle, $src, $deps, $ver, $media );
}

/**
 * Override core admin styles with forked versions from the plugin.
 *
 * Runs at priority 15 on wp_default_styles, after core registers styles at priority 10.
 *
 * @param WP_Styles $styles WP_Styles instance.
 */
function admin_redesign_register_style_overrides( $styles ) {
	// Use plugin version in production, time() for development.
	$version = defined( 'ADMIN_REDESIGN_VERSION' ) && ! ( defined( 'SCRIPT_DEBUG' ) && SCRIPT_DEBUG )
		? ADMIN_REDESIGN_VERSION
		: time();

	$base_url  = ADMIN_REDESIGN_URL . 'core-styles/';
	$base_path = ADMIN_REDESIGN_PATH . 'core-styles/';

	/**
	 * Map of handles to override.
	 *
	 * Format: handle => [ 'path' => relative path, 'deps' => dependencies or null to preserve ]
	 *
	 * When deps is null, we preserve the original dependencies from core.
	 */
	$style_overrides = array(
		// wp-admin/css/ styles.
		'common'      => array(
			'path' => 'wp-admin/css/common.css',
			'deps' => null,
		),
		'forms'       => array(
			'path' => 'wp-admin/css/forms.css',
			'deps' => null,
		),
		'admin-menu'  => array(
			'path' => 'wp-admin/css/admin-menu.css',
			'deps' => null,
		),
		'dashboard'   => array(
			'path' => 'wp-admin/css/dashboard.css',
			'deps' => null,
		),
		'list-tables' => array(
			'path' => 'wp-admin/css/list-tables.css',
			'deps' => null,
		),
		'edit'        => array(
			'path' => 'wp-admin/css/edit.css',
			'deps' => null,
		),
		'revisions'   => array(
			'path' => 'wp-admin/css/revisions.css',
			'deps' => null,
		),
		'media'       => array(
			'path' => 'wp-admin/css/media.css',
			'deps' => null,
		),
		'themes'      => array(
			'path' => 'wp-admin/css/themes.css',
			'deps' => null,
		),
		'about'       => array(
			'path' => 'wp-admin/css/about.css',
			'deps' => null,
		),
		'nav-menus'   => array(
			'path' => 'wp-admin/css/nav-menus.css',
			'deps' => null,
		),
		'widgets'     => array(
			'path' => 'wp-admin/css/widgets.css',
			'deps' => null,
		),
		'site-icon'   => array(
			'path' => 'wp-admin/css/site-icon.css',
			'deps' => null,
		),
		'l10n'        => array(
			'path' => 'wp-admin/css/l10n.css',
			'deps' => null,
		),
		'site-health' => array(
			'path' => 'wp-admin/css/site-health.css',
			'deps' => null,
		),
		'login'       => array(
			'path' => 'wp-admin/css/login.css',
			'deps' => null,
		),
		'install'     => array(
			'path' => 'wp-admin/css/install.css',
			'deps' => null,
		),

		// wp-includes/css/ styles.
		'buttons'     => array(
			'path' => 'wp-includes/css/buttons.css',
			'deps' => null,
		),
		'admin-bar'   => array(
			'path' => 'wp-includes/css/admin-bar.css',
			'deps' => null,
		),
		'media-views' => array(
			'path' => 'wp-includes/css/media-views.css',
			'deps' => null,
		),
	);

	foreach ( $style_overrides as $handle => $config ) {
		$file_path = $base_path . $config['path'];

		// Only override if the forked file exists.
		if ( ! file_exists( $file_path ) ) {
			continue;
		}

		// Get original style to preserve dependencies if needed.
		$original = $styles->query( $handle, 'registered' );
		$deps     = $config['deps'] ?? ( $original ? $original->deps : array() );

		// Deregister and re-register with plugin URL.
		admin_redesign_override_style(
			$styles,
			$handle,
			$base_url . $config['path'],
			$deps,
			$version
		);

		// Tell WordPress to automatically load -rtl.css variant for RTL sites.
		$styles->add_data( $handle, 'rtl', 'replace' );

		// Set file path for potential inlining.
		$styles->add_data( $handle, 'path', $file_path );
	}
}
add_action( 'wp_default_styles', 'admin_redesign_register_style_overrides', 15 );

/**
 * Override color scheme URLs to use forked versions.
 *
 * Color schemes are registered via wp_admin_css_color() and stored in
 * the global $_wp_admin_css_colors. We modify the URL property directly.
 */
function admin_redesign_override_color_schemes() {
	global $_wp_admin_css_colors;

	if ( empty( $_wp_admin_css_colors ) ) {
		return;
	}

	$base_url  = ADMIN_REDESIGN_URL . 'core-styles/wp-admin/css/colors/';
	$base_path = ADMIN_REDESIGN_PATH . 'core-styles/wp-admin/css/colors/';

	foreach ( $_wp_admin_css_colors as $scheme => $data ) {
		$forked_path = $base_path . $scheme . '/colors.css';

		if ( file_exists( $forked_path ) ) {
			$_wp_admin_css_colors[ $scheme ]->url = $base_url . $scheme . '/colors.css';
		}
	}
}
add_action( 'admin_init', 'admin_redesign_override_color_schemes', 5 );

