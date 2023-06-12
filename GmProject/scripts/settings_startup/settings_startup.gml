/// settings_startup()

function settings_startup()
{
	trial_startup()
	
	setting_advanced_mode = dev_mode_advanced
	
	setting_minecraft_assets_version = minecraft_version
	setting_minecraft_assets_new_version = ""
	setting_minecraft_assets_new_format = 0
	setting_minecraft_assets_new_changes = ""
	setting_minecraft_assets_new_image = ""
	
	setting_project_folder = projects_directory
	directory_create_lib(setting_project_folder)
	
	closed_toast_list = ds_list_create()
	
	backup_text_ani = 0
	backup_next = 0
	setting_backup = true
	setting_backup_time = 3
	setting_backup_amount = 5
	setting_spawn_cameras = true
	setting_unlimited_values = false
	
	setting_watermark_custom = false
	setting_watermark_fn = ""
	setting_watermark_image = null
	setting_watermark_halign = "right"
	setting_watermark_valign = "bottom"
	setting_watermark_padding = 0
	setting_watermark_scale = .33
	setting_watermark_opacity = 1
	
	setting_theme = theme_light
	setting_accent = 3
	setting_accent_custom = hex_to_color("03A9F4")
	
	setting_language_filename = language_file
	
	setting_timeline_autoscroll = true
	setting_timeline_compact = false
	setting_timeline_show_markers = true
	setting_timeline_select_jump = true
	setting_timeline_hide_ghosts = false
	setting_timeline_frame_snap = false
	setting_z_is_up = false
	setting_search_variants = true
	setting_separate_tool_modes = false
	setting_show_shortcuts_bar = true
	setting_gizmos_face_camera = true
	setting_fade_gizmos = true
	setting_camera_lock_mouse = (platform_get() != e_platform.MAC_OS)
	setting_place_new = true
	setting_interface_scale_auto = true
	setting_interface_scale = interface_scale_default_get()
	setting_interface_compact = false
	
	setting_panel_left_bottom_size = 300
	setting_panel_right_bottom_size = 300
	setting_panel_bottom_size = 300
	setting_panel_top_size = 205
	setting_panel_left_top_size = 300
	setting_panel_right_top_size = 300
	
	setting_properties_location = "right"
	setting_ground_editor_location = "right_secondary"
	setting_template_editor_location = "right_secondary"
	setting_timeline_editor_location = "right"
	setting_frame_editor_location = "right_secondary"
	setting_settings_location = "right_secondary"
	
	setting_view_split = 0.5
	
	setting_view_main_overlays = true
	setting_view_main_aspect_ratio = false
	setting_view_main_grid = false
	setting_view_main_gizmos = true
	setting_view_main_fog = true
	setting_view_main_effects = true
	setting_view_main_particles = true
	setting_view_main_location = "full"
	
	setting_view_second_show = false
	setting_view_second_overlays = true
	setting_view_second_aspect_ratio = true
	setting_view_second_grid = false
	setting_view_second_gizmos = false
	setting_view_second_fog = true
	setting_view_second_effects = true
	setting_view_second_particles = true
	setting_view_second_location = "right_bottom"
	setting_view_second_width = 440
	setting_view_second_height = 280
	
	setting_modelbench_popup_hidden = false
	
	setting_move_speed = 1
	setting_look_sensitivity = 1
	setting_fast_modifier = 3
	setting_slow_modifier = 0.25
	
	setting_scenery_remove_edges = true
	
	setting_export_movie_format = "mp4"
	setting_export_movie_frame_rate = 30
	setting_export_movie_framespersecond = 30
	setting_export_movie_bit_rate = 2500000
	setting_export_movie_include_audio = true
	setting_export_movie_remove_background = false
	setting_export_movie_include_hidden = false
	setting_export_movie_high_quality = true
	setting_export_movie_watermark = trial_version
	
	setting_export_image_remove_background = false
	setting_export_image_include_hidden = false
	setting_export_image_high_quality = true
	setting_export_image_watermark = trial_version
	
	project_render_pass = e_render_pass.COMBINED
	
	// World import
	setting_world_import_filter_enabled = false
	setting_world_import_filter_mode = 0
	setting_world_import_filter_list = ds_list_create()
	setting_world_import_unload_regions = true
	
	// Viewport
	setting_snap = false
	setting_snap_absolute = true
	setting_snap_size_position = 1
	setting_snap_size_rotation = 15
	setting_snap_size_scale = 1
	
	setting_tool_select = false
	setting_tool_move = true
	setting_tool_rotate = true
	setting_tool_scale = false
	setting_tool_bend = true
	setting_tool_transform = false
	
	setting_main_window_rect = null
	setting_main_window_maximized = true
	
	// New UI settings
	setting_reduced_motion = false
	setting_wind_enable = true
	
	settings_load()
	languages_load()
	interface_update_instant()
}
