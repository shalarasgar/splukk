// ─────────────────────────────────────────────────────────────────────────────
// AUTO-MANAGED: mirrors assets/translations/*.json structure.
// Usage: LocaleKeys.auth_login.tr()
// ─────────────────────────────────────────────────────────────────────────────
abstract class LocaleKeys {
  // ── Navigation ──────────────────────────────────────────────────────────────
  static const nav_search        = 'nav.search';
  static const nav_my_picks      = 'nav.my_picks';
  static const nav_profile       = 'nav.profile';

  // ── Marketplace ─────────────────────────────────────────────────────────────
  static const marketplace_hero_title    = 'marketplace.hero_title';
  static const marketplace_hero_subtitle = 'marketplace.hero_subtitle';
  static const marketplace_no_results    = 'marketplace.no_results';
  static const marketplace_map_view      = 'marketplace.map_view';
  static const marketplace_list_view     = 'marketplace.list_view';
  static const marketplace_search_hint   = 'marketplace.search_hint';
  static const marketplace_plan_visit   = 'marketplace.plan_visit';
  static const marketplace_categories   = 'marketplace.categories';

  // ── Categories ──────────────────────────────────────────────────────────────
  static const categories_all        = 'categories.all';
  static const categories_berries    = 'categories.berries';
  static const categories_fruits     = 'categories.fruits';
  static const categories_vegetables = 'categories.vegetables';
  static const categories_herbs      = 'categories.herbs';
  static const categories_flowers    = 'categories.flowers';

  // ── Products ────────────────────────────────────────────────────────────────
  static const products_strawberry = 'products.strawberry';
  static const products_raspberry = 'products.raspberry';
  static const products_blueberry = 'products.blueberry';
  static const products_blackcurrant = 'products.blackcurrant';
  static const products_redcurrant = 'products.redcurrant';
  static const products_gooseberry = 'products.gooseberry';
  static const products_blackberry = 'products.blackberry';
  static const products_cultivated_blueberry = 'products.cultivated_blueberry';
  static const products_apple = 'products.apple';
  static const products_pear = 'products.pear';
  static const products_plum = 'products.plum';
  static const products_cherry = 'products.cherry';
  static const products_sweet_cherry = 'products.sweet_cherry';
  static const products_rhubarb = 'products.rhubarb';
  static const products_grape = 'products.grape';
  static const products_potato = 'products.potato';
  static const products_carrot = 'products.carrot';
  static const products_onion = 'products.onion';
  static const products_garlic = 'products.garlic';
  static const products_leek = 'products.leek';
  static const products_beetroot = 'products.beetroot';
  static const products_turnip = 'products.turnip';
  static const products_rutabaga = 'products.rutabaga';
  static const products_radish = 'products.radish';
  static const products_lettuce = 'products.lettuce';
  static const products_spinach = 'products.spinach';
  static const products_kale = 'products.kale';
  static const products_white_cabbage = 'products.white_cabbage';
  static const products_red_cabbage = 'products.red_cabbage';
  static const products_cauliflower = 'products.cauliflower';
  static const products_broccoli = 'products.broccoli';
  static const products_celery = 'products.celery';
  static const products_celeriac = 'products.celeriac';
  static const products_sugar_snap_peas = 'products.sugar_snap_peas';
  static const products_peas = 'products.peas';
  static const products_beans = 'products.beans';
  static const products_cucumber = 'products.cucumber';
  static const products_zucchini = 'products.zucchini';
  static const products_pumpkin = 'products.pumpkin';
  static const products_corn = 'products.corn';
  static const products_parsley = 'products.parsley';
  static const products_dill = 'products.dill';
  static const products_chives = 'products.chives';
  static const products_basil = 'products.basil';
  static const products_mint = 'products.mint';
  static const products_thyme = 'products.thyme';
  static const products_rosemary = 'products.rosemary';
  static const products_sunflower = 'products.sunflower';
  static const products_dahlia = 'products.dahlia';
  static const products_tulip = 'products.tulip';
  static const products_peony = 'products.peony';
  static const products_summer_flowers = 'products.summer_flowers';

  // ── Auth ─────────────────────────────────────────────────────────────────────
  static const auth_welcome              = 'auth.welcome';
  static const auth_welcome_subtitle     = 'auth.welcome_subtitle';
  static const auth_login_required       = 'auth.login_required';
  static const auth_login                = 'auth.login';
  static const auth_register_consumer    = 'auth.register_consumer';
  static const auth_register_farmer      = 'auth.register_farmer';
  static const auth_register             = 'auth.register';
  static const auth_phone_label          = 'auth.phone_label';
  static const auth_phone_hint           = 'auth.phone_hint';
  static const auth_send_sms             = 'auth.send_sms';
  static const auth_full_name            = 'auth.full_name';
  static const auth_farm_name            = 'auth.farm_name';
  static const auth_postal_code          = 'auth.postal_code';
  static const auth_street               = 'auth.street';
  static const auth_building_number      = 'auth.building_number';
  static const auth_logo_add             = 'auth.logo_add';
  static const auth_logo_selected        = 'auth.logo_selected';
  static const auth_sms_verification     = 'auth.sms_verification';
  static const auth_sms_instructions     = 'auth.sms_instructions';
  static const auth_verification_code    = 'auth.verification_code';
  static const auth_verify_complete      = 'auth.verify_complete';
  static const auth_error_phone_empty    = 'auth.error_phone_empty';
  static const auth_error_name_empty     = 'auth.error_name_empty';
  static const auth_error_farm_required  = 'auth.error_farm_required';
  static const auth_error_street_required = 'auth.error_street_required';
  // ── Auth error codes (emitted by AuthBloc, translated in UI) ────────────────
  static const auth_error_farm_location_required  = 'auth.error_farm_location_required';
  static const auth_error_address_not_found        = 'auth.error_address_not_found';
  static const auth_error_no_account               = 'auth.error_no_account';
  static const auth_error_verification_id_missing  = 'auth.error_verification_id_missing';
  static const auth_error_farm_address_incomplete  = 'auth.error_farm_address_incomplete';

  // ── Location ─────────────────────────────────────────────────────────────────
  static const location_country                  = 'location.country';
  static const location_state                    = 'location.state';
  static const location_city                     = 'location.city';
  static const location_search_country           = 'location.search_country';
  static const location_search_state             = 'location.search_state';
  static const location_search_city              = 'location.search_city';
  static const location_geolocation_disabled     = 'location.geolocation_disabled';
  static const location_geolocation_denied       = 'location.geolocation_denied';
  static const location_geolocation_denied_forever = 'location.geolocation_denied_forever';

  // ── Profile ──────────────────────────────────────────────────────────────────
  static const profile_farmer_badge          = 'profile.farmer_badge';
  static const profile_consumer_badge        = 'profile.consumer_badge';
  static const profile_farmer_dashboard      = 'profile.farmer_dashboard';
  static const profile_section_account       = 'profile.section_account';
  static const profile_section_content       = 'profile.section_content';
  static const profile_section_app           = 'profile.section_app';
  static const profile_notifications         = 'profile.notifications';
  static const profile_security              = 'profile.security';
  static const profile_privacy               = 'profile.privacy';
  static const profile_favorites             = 'profile.favorites';
  static const profile_media                 = 'profile.media';
  static const profile_appearance            = 'profile.appearance';
  static const profile_language              = 'profile.language';
  static const profile_help                  = 'profile.help';
  static const profile_about                 = 'profile.about';
  static const profile_logout                = 'profile.logout';
  static const profile_logout_confirm_title  = 'profile.logout_confirm_title';
  static const profile_logout_confirm_body   = 'profile.logout_confirm_body';
  static const profile_cancel                = 'profile.cancel';
  static const profile_coming_soon           = 'profile.coming_soon';

  // ── Farmer profile ───────────────────────────────────────────────────────────
  static const farmer_profile_call     = 'farmer_profile.call';
  static const farmer_profile_send_sms = 'farmer_profile.send_sms';
  static const farmer_profile_error    = 'farmer_profile.error';
  static const farmer_profile_title    = 'farmer_profile.title';
  static const farmer_profile_info     = 'farmer_profile.info';
  static const farmer_profile_social   = 'farmer_profile.social';
  static const farmer_profile_member   = 'farmer_profile.member';
  static const farmer_profile_not_found = 'farmer_profile.not_found';

  // ── Edit profile ─────────────────────────────────────────────────────────────
  static const edit_profile_title           = 'edit_profile.title';
  static const edit_profile_save            = 'edit_profile.save';
  static const edit_profile_success         = 'edit_profile.success';
  static const edit_profile_error           = 'edit_profile.error';
  static const edit_profile_section_basic   = 'edit_profile.section_basic';
  static const edit_profile_farm_name       = 'edit_profile.farm_name';
  static const edit_profile_full_name       = 'edit_profile.full_name';
  static const edit_profile_farm_desc       = 'edit_profile.farm_desc';
  static const edit_profile_about_me        = 'edit_profile.about_me';
  static const edit_profile_section_contact = 'edit_profile.section_contact';
  static const edit_profile_alt_phone       = 'edit_profile.alt_phone';
  static const edit_profile_section_social  = 'edit_profile.section_social';
  static const edit_profile_insta           = 'edit_profile.insta';
  static const edit_profile_fb              = 'edit_profile.fb';
  static const edit_profile_section_payment = 'edit_profile.section_payment';
  static const edit_profile_iban            = 'edit_profile.iban';
  static const edit_profile_save_changes    = 'edit_profile.save_changes';

  // ── Listings ─────────────────────────────────────────────────────────────────
  static const listings_details       = 'listings.details';
  static const listings_map           = 'listings.map';
  static const listings_book_now      = 'listings.book_now';
  static const listings_available     = 'listings.available';
  static const listings_unavailable   = 'listings.unavailable';
  static const listings_guests        = 'listings.guests';
  static const listings_picking_self  = 'listings.picking_self';
  static const listings_picking_prepicked = 'listings.picking_prepicked';
  static const listings_error_map     = 'listings.error_map';
  static const listings_open          = 'listings.open';
  static const listings_closed        = 'listings.closed';
  static const listings_directions    = 'listings.directions';
  static const listings_status        = 'listings.status';
  static const listings_picking_type  = 'listings.picking_type';
  static const listings_products      = 'listings.products';
  static const listings_schedule_booking = 'listings.schedule_booking';
  static const listings_full          = 'listings.full';
  static const listings_free          = 'listings.free';
  static const listings_active_booking = 'listings.active_booking';
  static const listings_how_many_guests = 'listings.how_many_guests';
  static const listings_max_guests    = 'listings.max_guests';
  static const listings_booking_updated = 'listings.booking_updated';
  static const listings_booking_success = 'listings.booking_success';
  static const listings_booking_cancelled = 'listings.booking_cancelled';

  // ── My Picks ─────────────────────────────────────────────────────────────────
  static const my_picks_title          = 'my_picks.title';
  static const my_picks_empty          = 'my_picks.empty';
  static const my_picks_empty_subtitle = 'my_picks.empty_subtitle';
  static const my_picks_planned_visits = 'my_picks.planned_visits';
  static const my_picks_date           = 'my_picks.date';
  static const my_picks_guests_count   = 'my_picks.guests_count';
  static const my_picks_time           = 'my_picks.time';
  static const my_picks_upcoming       = 'my_picks.upcoming';
  static const my_picks_past           = 'my_picks.past';
  static const my_picks_retry          = 'my_picks.retry';

  // ── Bookings ─────────────────────────────────────────────────────────────────
  static const bookings_title          = 'bookings.title';
  static const bookings_active         = 'bookings.active';
  static const bookings_past           = 'bookings.past';
  static const bookings_cancel         = 'bookings.cancel';
  static const bookings_update         = 'bookings.update';
  static const bookings_cancel_confirm = 'bookings.cancel_confirm';

  // ── Common ───────────────────────────────────────────────────────────────────
  static const common_loading       = 'common.loading';
  static const common_error_generic = 'common.error_generic';
  static const common_retry         = 'common.retry';
  static const common_close         = 'common.close';
  static const common_save          = 'common.save';
  static const common_cancel        = 'common.cancel';
  static const common_confirm       = 'common.confirm';
  static const common_back          = 'common.back';
  static const common_yes           = 'common.yes';
  static const common_no            = 'common.no';
  static const common_all           = 'common.all';

  // ── Exit dialog ──────────────────────────────────────────────────────────────
  static const exit_dialog_title = 'exit_dialog.title';
  static const exit_dialog_body  = 'exit_dialog.body';
  static const exit_dialog_exit  = 'exit_dialog.exit';
  static const exit_dialog_stay  = 'exit_dialog.stay';

  // ── Farmer Listing Form ─────────────────────────────────────────────────────
  static const farmer_listing_form_new_title       = 'farmer_listing_form.new_title';
  static const farmer_listing_form_edit_title      = 'farmer_listing_form.edit_title';
  static const farmer_listing_form_preview_title   = 'farmer_listing_form.preview_title';
  static const farmer_listing_form_preview_subtitle = 'farmer_listing_form.preview_subtitle';
  static const farmer_listing_form_section_farm_info = 'farmer_listing_form.section_farm_info';
  static const farmer_listing_form_images_label    = 'farmer_listing_form.images_label';
  static const farmer_listing_form_add             = 'farmer_listing_form.add';
  static const farmer_listing_form_read_only_hint  = 'farmer_listing_form.read_only_hint';
  static const farmer_listing_form_description     = 'farmer_listing_form.description';
  static const farmer_listing_form_description_hint = 'farmer_listing_form.description_hint';
  static const farmer_listing_form_product         = 'farmer_listing_form.product';
  static const farmer_listing_form_price           = 'farmer_listing_form.price';
  static const farmer_listing_form_price_hint      = 'farmer_listing_form.price_hint';
  static const farmer_listing_form_unit            = 'farmer_listing_form.unit';
  static const farmer_listing_form_unit_kg         = 'farmer_listing_form.unit_kg';
  static const farmer_listing_form_unit_package    = 'farmer_listing_form.unit_package';
  static const farmer_listing_form_calendar        = 'farmer_listing_form.calendar';
  static const farmer_listing_form_capacity        = 'farmer_listing_form.capacity';
  static const farmer_listing_form_picking_type    = 'farmer_listing_form.picking_type';
  static const farmer_listing_form_remaining_stock = 'farmer_listing_form.remaining_stock';
  static const farmer_listing_form_availability_msg = 'farmer_listing_form.availability_msg';
  static const farmer_listing_form_suggested_text  = 'farmer_listing_form.suggested_text';
  static const farmer_listing_form_visibility      = 'farmer_listing_form.visibility';
  static const farmer_listing_form_visibility_hint = 'farmer_listing_form.visibility_hint';
  static const farmer_listing_form_activate        = 'farmer_listing_form.activate';
  static const farmer_listing_form_delete          = 'farmer_listing_form.delete';
  static const farmer_listing_form_cancel          = 'farmer_listing_form.cancel';
  static const farmer_listing_form_confirm_delete_title = 'farmer_listing_form.confirm_delete_title';
  static const farmer_listing_form_confirm_delete_body  = 'farmer_listing_form.confirm_delete_body';
  static const farmer_listing_form_error_no_products   = 'farmer_listing_form.error_no_products';
  static const farmer_listing_form_error_no_schedule   = 'farmer_listing_form.error_no_schedule';
  static const farmer_listing_form_error_farm_required = 'farmer_listing_form.error_farm_required';
  static const farmer_listing_form_error_location_required = 'farmer_listing_form.error_location_required';
  static const farmer_listing_form_error_location_required_desc = 'farmer_listing_form.error_location_required_desc';
  static const farmer_listing_form_error_invalid_price      = 'farmer_listing_form.error_invalid_price';
  static const farmer_listing_form_error_capacity_min       = 'farmer_listing_form.error_capacity_min';
  static const farmer_listing_form_error_end_time           = 'farmer_listing_form.error_end_time';
  static const farmer_listing_form_save_success        = 'farmer_listing_form.save_success';
  static const farmer_listing_form_save_failure        = 'farmer_listing_form.save_failure';
  static const farmer_listing_form_mock_farm_name      = 'farmer_listing_form.mock_farm_name';
  static const farmer_listing_form_mock_city           = 'farmer_listing_form.mock_city';

  // ── Farmer Dashboard ────────────────────────────────────────────────────────
  static const farmer_dashboard_title                = 'farmer_dashboard.title';
  static const farmer_dashboard_sign_out             = 'farmer_dashboard.sign_out';
  static const farmer_dashboard_auth_required        = 'farmer_dashboard.auth_required';
  static const farmer_dashboard_no_listings          = 'farmer_dashboard.no_listings';
  static const farmer_dashboard_create_listing       = 'farmer_dashboard.create_listing';
  static const farmer_dashboard_delete_confirm_title = 'farmer_dashboard.delete_confirm_title';
  static const farmer_dashboard_delete_confirm_body  = 'farmer_dashboard.delete_confirm_body';
  static const farmer_dashboard_delete_success       = 'farmer_dashboard.delete_success';

  // ── Availability ────────────────────────────────────────────────────────────
  static const availability_low              = 'availability.low';
  static const availability_low_stock        = 'availability.low_stock';
  static const availability_low_miss         = 'availability.low_miss';
  static const availability_medium_limited   = 'availability.medium_limited';
  static const availability_medium_plan      = 'availability.medium_plan';
  static const availability_medium_soon      = 'availability.medium_soon';
  static const availability_high_good        = 'availability.high_good';
  static const availability_high_easy        = 'availability.high_easy';
  static const availability_high_sufficient  = 'availability.high_sufficient';
  static const availability_full_abundant    = 'availability.full_abundant';
  static const availability_full_great       = 'availability.full_great';
  static const availability_full_pleasant    = 'availability.full_pleasant';
}
