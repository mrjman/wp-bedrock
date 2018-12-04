<?php
  /**
   * Returns the URL for the front end of the site
  */
  function frontend_url() {
    return getenv( 'COA_FRONTEND_URL' );
  }

  /**
   * Respond to a REST API request to get a post's latest revision.
   * * Requires a valid _wpnonce on the query string
   * * User must have 'edit_posts' rights
   * * Will return draft revisions of even published posts
   *
   * @param  WP_REST_Request $request Rest request.
   * @return WP_REST_Response
  */
  function rest_get_post_preview( WP_REST_Request $request ) {
    $post_id = $request->get_param( 'id' );
    // Revisions are drafts so here we remove the default 'publish' status
    remove_action( 'pre_get_posts', 'set_default_status_to_publish' );
    $check_enabled = [
      'check_enabled' => false,
    ];
    if ( $revisions = wp_get_post_revisions( $post_id, $check_enabled ) ) {
      $last_revision = reset( $revisions );
      $rev_post = wp_get_post_revision( $last_revision->ID );
      $controller = new WP_REST_Posts_Controller( 'post' );
      $data = $controller->prepare_item_for_response( $rev_post, $request );
    } elseif ( $post = get_post( $post_id ) ) { // There are no revisions, just return the saved parent post
      $controller = new WP_REST_Posts_Controller( 'post' );
      $data = $controller->prepare_item_for_response( $post, $request );
    } else {
      $not_found = [
        'status' => 404,
      ];
      $error = new WP_Error(
        'rest_get_post_preview',
        'Post ' . $post_id . ' does not exist',
        $not_found
      );
      return $error;
    }
    $response = $controller->prepare_response_for_collection( $data );
    return new WP_REST_Response( $response );
  }

  /**
   * Register a preview route for posts
  */
  register_rest_route('coachella-headless/v1', '/post/preview', [
    'methods'  => 'GET',
    'callback' => 'rest_get_post_preview',
    'args' => [
      'id' => [
        'validate_callback' => function ( $param, $request, $key ) {
          return ( is_numeric( $param ) );
        },
        'required' => true,
        'description' => 'Valid WordPress post ID',
      ],
    ],
    'permission_callback' => function () {
      return current_user_can( 'edit_posts' );
    },
    ] );

  /**
   * Customize the preview button in the WordPress admin to point to the headless client.
   *
   * @param  str $link The WordPress preview link.
   * @return str The headless WordPress preview link.
  */
  function set_headless_preview_link( $link ) {
    return create_headless_preview_link( get_the_ID() );
  }

  /**
   * Creates preview link for headless application
   * Format: frontend_url/_preview/:post_id/:_wpnonce
   *
   * @param  number $post_id ID of the post to build the linke for
   * @return str The preview url
   */
  function create_headless_preview_link( $post_id ) {
    // Builds preview link matching permalink
    // $post = get_post( $post_id );
    //
    // if ( in_array( $post->post_status, array( 'draft', 'pending', 'future', 'auto-draft' ) ) ) {
    //   $my_post = clone $post;
    //   $my_post->post_status = 'publish';
    //   $my_post->post_name = sanitize_title(
    //     $my_post->post_name ? $my_post->post_name : $my_post->post_title,
    //     $my_post->ID
    //   );
    //   $permalink = get_permalink( $my_post );
    // } else {
    //   $permalink = get_permalink( $post_id );
    // }
    //
    // $preview_url = wp_nonce_url(str_replace( home_url(), frontend_url(), $permalink ) . 'preview', 'wp_rest');

    $preview_url = frontend_url() . '/' . '_preview' . '/' . $post_id . '/' . wp_create_nonce('wp_rest');

    return $preview_url;
  }

  /**
   * Register custom preview link
   */
  add_filter( 'preview_post_link', 'set_headless_preview_link' );
?>
