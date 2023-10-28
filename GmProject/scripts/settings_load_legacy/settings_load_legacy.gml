/// settings_load_legacy(filename)
/// @arg filename

function settings_load_legacy(fn)
{
	log("Loading legacy settings", fn)
	
	buffer_current = buffer_load_lib(fn)
	load_format = buffer_read_byte()
	log("load_format", load_format)
	
	if (load_format >= e_settings.FORMAT_110_PRE_1)
	{
		buffer_delete(buffer_current)
		return 0
	}
	
	if (load_format >= e_settings.FORMAT_100)
	{
		room_speed = buffer_read_byte()
		if (dev_mode)
			buffer_read_string_int()
		else
			setting_project_folder = buffer_read_string_int()
	}
	
	setting_backup = buffer_read_byte()
	setting_backup_time = buffer_read_byte()
	setting_backup_amount = buffer_read_byte()
	if (load_format < e_settings.FORMAT_100)
		/*setting_copy_projects=*/buffer_read_byte()
	
	if (load_format >= e_settings.FORMAT_100_DEMO_5)
	{
		/*setting_spawn_objects = */buffer_read_byte()
		setting_spawn_cameras = buffer_read_byte()
	}
	
	/*setting_tip_show = */buffer_read_byte()
	/*setting_tip_delay = */buffer_read_double()
	
	if (load_format >= e_settings.FORMAT_100)
	{
		/*setting_view_grid_size_hor = */buffer_read_byte()
		/*setting_view_grid_size_ver = */buffer_read_byte()
	}
	if (load_format >= e_settings.FORMAT_103)
	{
		/*setting_view_real_time_render = */buffer_read_byte()
		/*setting_view_real_time_render_time = */buffer_read_int()
	}
	
	/*setting_font_filename = */buffer_read_string_int()
	
	/*
	if (!file_exists_lib(setting_font_filename))
		setting_font_filename = ""
	
	if (setting_font_filename != "") 
	{
		setting_font = font_add_lib(setting_font_filename, 10, 0, 0)
		setting_font_bold = font_add_lib(setting_font_filename, 10, 1, 0)
	}
	*/
	
	/*setting_language_filename = */buffer_read_string_int()
	
	if (load_format < e_settings.FORMAT_100)
	{
		/*setting_color=*/buffer_read_int()
		/*setting_color_text=*/buffer_read_int()
		/*setting_color_highlight=*/buffer_read_int()
		/*setting_color_highlight_text=*/buffer_read_int()
		/*setting_color_boxes=*/buffer_read_int()
		/*setting_color_boxes_text=*/buffer_read_int()
		/*setting_color_buttons=*/buffer_read_int()
		/*setting_color_buttons_text=*/buffer_read_int()
		/*setting_color_timeline=*/buffer_read_int()
		/*setting_color_timeline_text=*/buffer_read_int()
	} 
	else
		settings_load_legacy_colors()
	
	setting_timeline_autoscroll = buffer_read_byte()
	if (load_format >= e_settings.FORMAT_103)
	{
		setting_timeline_compact = buffer_read_byte()
		setting_timeline_select_jump = buffer_read_byte()
	}
	
	if (load_format >= e_settings.FORMAT_100)
		setting_z_is_up = buffer_read_byte()
	
	// Pre-2.0 keybinds not supported, just read buffer data
	
	// Workaround a bug where the keys are saved as "0", causing them to continuously pressed
	var keynew = buffer_read_byte();
	/*var keynewcontrol = */buffer_read_byte();
	var keyimportasset = null;
	var keyimportassetcontrol = null;
	
	if (load_format >= e_settings.FORMAT_100)
	{
		keyimportasset = buffer_read_byte();
		keyimportassetcontrol = buffer_read_byte()
	}
	
	var keyopen = buffer_read_byte();
	/*var keyopencontrol = */buffer_read_byte();
	var keysave = buffer_read_byte();
	/*var keysavecontrol = */buffer_read_byte();
	
	if (keynew = 0 || keyimportasset = 0 || keyopen = 0 || keysave = 0)
	{
		buffer_delete(buffer_current)
		return 0
	}
	
	/*
	setting_key_open = keyopen
	setting_key_open_control = keyopencontrol
	setting_key_save = keysave
	setting_key_save_control = keysavecontrol
	
	setting_key_new = keynew
	setting_key_new_control = keynewcontrol
	setting_key_import_asset = keyimportasset
	setting_key_import_asset_control = keyimportassetcontrol
	*/
	
	if (load_format >= e_settings.FORMAT_100)
	{
		/*setting_key_undo = */buffer_read_byte()
		/*setting_key_undo_control = */buffer_read_byte()
		/*setting_key_redo = */buffer_read_byte()
		/*setting_key_redo_control = */buffer_read_byte()
		/*setting_key_play = */buffer_read_byte()
		/*setting_key_play_control = */buffer_read_byte()
		/*setting_key_play_beginning = */buffer_read_byte()
		/*setting_key_play_beginning_control = */buffer_read_byte()
		/*setting_key_move_marker_right = */buffer_read_byte()
		/*setting_key_move_marker_right_control = */buffer_read_byte()
		/*setting_key_move_marker_left = */buffer_read_byte()
		/*setting_key_move_marker_left_control = */buffer_read_byte()
		/*setting_key_render = */buffer_read_byte()
		/*setting_key_render_control = */buffer_read_byte()
		/*setting_key_folder = */buffer_read_byte()
		/*setting_key_folder_control = */buffer_read_byte()
		/*setting_key_select_timelines = */buffer_read_byte()
		/*setting_key_select_timelines_control = */buffer_read_byte()
		/*setting_key_duplicate_timelines = */buffer_read_byte()
		/*setting_key_duplicate_timelines_control = */buffer_read_byte()
		/*setting_key_remove_timelines = */buffer_read_byte()
		/*setting_key_remove_timelines_control = */buffer_read_byte()
	}
	
	/*setting_key_copy_keyframes = */buffer_read_byte()
	/*setting_key_copy_keyframes_control = */buffer_read_byte()
	/*setting_key_cut_keyframes = */buffer_read_byte()
	/*setting_key_cut_keyframes_control = */buffer_read_byte()
	/*setting_key_paste_keyframes = */buffer_read_byte()
	/*setting_key_paste_keyframes_control = */buffer_read_byte()
	/*setting_key_remove_keyframes = */buffer_read_byte()
	/*setting_key_remove_keyframes_control = */buffer_read_byte()
	/*setting_key_spawn_particles = */buffer_read_byte()
	/*setting_key_spawn_particles_control = */buffer_read_byte()
	/*setting_key_clear_particles = */buffer_read_byte()
	/*setting_key_clear_particles_control = */buffer_read_byte()
	
	if (load_format < e_settings.FORMAT_100)
	{
		/*setting_key_play = */buffer_read_byte()
		/*setting_key_play_control = */buffer_read_byte()
		/*setting_key_play_beginning = */buffer_read_byte()
		/*setting_key_play_beginning_control = */buffer_read_byte()
	}
	
	/*setting_key_forward = */buffer_read_byte()
	/*setting_key_back = */buffer_read_byte()
	/*setting_key_left = */buffer_read_byte()
	/*setting_key_right = */buffer_read_byte()
	/*setting_key_ascend = */buffer_read_byte()
	/*setting_key_descend = */buffer_read_byte()
	/*setting_key_roll_forward = */buffer_read_byte()
	/*setting_key_roll_back = */buffer_read_byte()
	/*setting_key_roll_reset = */buffer_read_byte()
	/*setting_key_reset = */buffer_read_byte()
	/*setting_key_fast = */buffer_read_byte()
	/*setting_key_slow = */buffer_read_byte()
	setting_move_speed = buffer_read_double()
	setting_look_sensitivity = buffer_read_double()
	setting_fast_modifier = buffer_read_double()
	setting_slow_modifier = buffer_read_double()
	
	/*setting_bend_round_default = */buffer_read_byte()
	/*setting_bend_detail = */buffer_read_int()
	/*setting_bend_scale = */buffer_read_double()
	setting_scenery_remove_edges = buffer_read_byte()
	
	if (load_format >= e_settings.FORMAT_106)
		project_render_liquid_animation = buffer_read_byte()
	
	if (load_format >= e_settings.FORMAT_100)
	{
		project_render_texture_filtering = buffer_read_byte()
		/*setting_transparent_texture_filtering = */buffer_read_byte()
		if (load_format >= e_settings.FORMAT_106_2)
			project_render_block_emissive = buffer_read_double()
		if (load_format < e_settings.FORMAT_106_3)
			/*setting_camera_buffer_size=*/buffer_read_int()
		
		project_render_ssao = buffer_read_byte()
		project_render_ssao_radius = buffer_read_double()
		project_render_ssao_power = buffer_read_double()
		/*project_render_ssao_blur_passes = */buffer_read_byte()
		project_render_ssao_color = buffer_read_int()
		
		project_render_shadows = buffer_read_byte()
	}
	
	project_render_shadows_sun_buffer_size = buffer_read_int()
	project_render_shadows_spot_buffer_size = buffer_read_int()
	project_render_shadows_point_buffer_size = buffer_read_int()
	
	if (load_format >= e_settings.FORMAT_100)
	{
		/*project_render_shadows_blur_quality =*/ buffer_read_byte()
		/*project_render_shadows_blur_size =*/ buffer_read_double()
		
		/*project_render_dof =*/ buffer_read_byte()
		/*project_render_dof_blur_size =*/ buffer_read_double()
		
		project_render_aa = buffer_read_byte()
		project_render_aa_power = buffer_read_double()
		
		/*setting_watermark*/ = buffer_read_byte()
		/*
		if (trial_version)
			setting_watermark = true
		*/
		
		/*setting_toolbar_location = */buffer_read_string_int()
		/*setting_toolbar_size = */buffer_read_double()
		
		setting_panel_left_bottom_size = buffer_read_double()
		setting_panel_right_bottom_size = buffer_read_double()
		setting_panel_bottom_bottom_size = buffer_read_double()
		setting_panel_top_size = buffer_read_double()
		setting_panel_left_top_size = buffer_read_double()
		setting_panel_right_top_size = buffer_read_double()
		
		var locarr = array("left_secondary", "right_secondary", "bottom", "top", "left", "right");
		setting_properties_location = locarr[buffer_read_byte()]
		setting_ground_editor_location = locarr[buffer_read_byte()]
		setting_template_editor_location = locarr[buffer_read_byte()]
		/*setting_timeline_location = */locarr[buffer_read_byte()]
		setting_timeline_editor_location = locarr[buffer_read_byte()]
		setting_frame_editor_location = locarr[buffer_read_byte()]
		setting_settings_location = locarr[buffer_read_byte()]
		
		setting_view_split = buffer_read_double()
		
		setting_view_main_overlays = buffer_read_byte()
		/*setting_view_main_lights*/ = buffer_read_byte()
		setting_view_main_particles = buffer_read_byte()
		setting_view_main_grid = buffer_read_byte()
		setting_view_main_aspect_ratio = buffer_read_byte()
		setting_view_main_location = buffer_read_string_int()
		
		setting_view_second_show = buffer_read_byte()
		setting_view_second_overlays = buffer_read_byte()
		/*setting_view_second_lights*/ = buffer_read_byte()
		setting_view_second_particles = buffer_read_byte()
		setting_view_second_grid = buffer_read_byte()
		setting_view_second_aspect_ratio = buffer_read_byte()
		setting_view_second_location = buffer_read_string_int()
		setting_view_second_width = buffer_read_double()
		setting_view_second_height = buffer_read_double()
		
		/*setting_frame_editor_color_advanced*/ = buffer_read_byte()
	}
	else
	{
		/*setting_camera_buffer_size=*/ buffer_read_int()
		project_render_shadows_blur_quality = buffer_read_byte()
		project_render_shadows_blur_size = min(buffer_read_double(), 4)
		/*project_render_dof_blur_size =*/ buffer_read_double()
	}
	
	if (load_format >= e_settings.FORMAT_106)
	{
		setting_export_movie_format = buffer_read_string_int()
		setting_export_movie_frame_rate = buffer_read_byte()
		setting_export_movie_bit_rate = buffer_read_int()
		setting_export_movie_include_audio = buffer_read_byte()
		setting_export_movie_remove_background = buffer_read_byte()
		setting_export_movie_include_hidden = buffer_read_byte()
		setting_export_movie_high_quality = buffer_read_byte()
		setting_export_image_remove_background = buffer_read_byte()
		setting_export_image_include_hidden = buffer_read_byte()
		setting_export_image_high_quality = buffer_read_byte()
	}
	if (load_format >= e_settings.FORMAT_CB_102)
	{
		/*setting_custom_interface = */buffer_read_byte()
		/*project_render_bloom = */buffer_read_byte()
	}
	
	buffer_delete(buffer_current)
}
