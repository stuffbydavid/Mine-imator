/// settings_load()
/// @desc Formats:
///			100 DEMO 4 = Initial
///			100 DEMO 5 = added spawn objects and camera
///			100 = added undo/redo shortcuts, project folder, ssao, shadows, dof, aa, grid size, even more shortcuts, panels, tabs, views, z is up, fps
///			103 = compact timeline, jump to select, real time render
///			106 = wave animation, exportmovie/image settings
///			106_2 = block brightness
///			106_3 = remove camera buffer size
///			110 = remade in JSON, texture filtering level

var fn = settings_file;

if (!file_exists_lib(fn))
	fn = data_directory + "settings.file"

if (!file_exists_lib(fn))
	return 0
	
if (filename_ext(fn) = ".midata")
{
	log("Loading settings", fn)
	
	// Decode
	var map = json_load(fn);
	if (!ds_map_valid(map))
		return 0
		
	if (!is_real(map[?"format"]))
		return 0
	
	load_format = map[?"format"];
	if (load_format > settings_format)
		return 0
	
	log("load_format", load_format)
	
	// Recent files
	var fileslist = map[?"recent_files"];
	if (ds_list_valid(fileslist))
	{
		for (var i = 0; i < ds_list_size(fileslist); i++)
		{
			var curfile = fileslist[|i];
			with (new(obj_recent))
			{
				filename = value_get_string(curfile[?"filename"])
				name = value_get_string(curfile[?"name"])
				author = value_get_string(curfile[?"author"])
				description = value_get_string(curfile[?"description"])
				date = value_get_real(curfile[?"date"])
		
				var thumbnailfn = filename_path(filename) + "thumbnail.png";
				if (file_exists_lib(thumbnailfn))
					thumbnail = texture_create(thumbnailfn)
				else
					thumbnail = null
		
				ds_list_add(app.recent_list, id)
			}
		}
	}
	
	// Program
	var programmap = map[?"program"];
	if (ds_map_valid(programmap))
	{
		room_speed = value_get_real(programmap[?"fps"], room_speed)
		if (!dev_mode)
			setting_project_folder = value_get_string(programmap[?"project_folder"], setting_project_folder)
		setting_backup = value_get_real(programmap[?"backup"], setting_backup)
		setting_backup_time = value_get_real(programmap[?"backup_time"], setting_backup_time)
		setting_backup_amount = value_get_real(programmap[?"backup_amount"], setting_backup_amount)
		setting_spawn_objects = value_get_real(programmap[?"spawn_objects"], setting_spawn_objects)
		setting_spawn_cameras = value_get_real(programmap[?"spawn_cameras"], setting_spawn_cameras)
	}
	
	// Interface
	var interfacemap = map[?"interface"];
	if (ds_map_valid(interfacemap))
	{
		setting_tip_show = value_get_real(interfacemap[?"tip_show"], setting_tip_show)
		setting_tip_delay = value_get_real(interfacemap[?"tip_delay"], setting_tip_delay)

		setting_view_grid_size_hor = value_get_real(interfacemap[?"view_grid_size_hor"], setting_view_grid_size_hor)
		setting_view_grid_size_ver = value_get_real(interfacemap[?"view_grid_size_ver"], setting_view_grid_size_ver)
		setting_view_real_time_render = value_get_real(interfacemap[?"view_real_time_render"], setting_view_real_time_render)
		setting_view_real_time_render_time = value_get_real(interfacemap[?"view_real_time_render_time"], setting_view_real_time_render_time)

		setting_font_filename = value_get_string(interfacemap[?"font_filename"], setting_font_filename)
		setting_language_filename = value_get_string(interfacemap[?"language_filename"], setting_language_filename)
		
		settings_load_colors(interfacemap[?"colors"])

		setting_timeline_autoscroll = value_get_real(interfacemap[?"timeline_autoscroll"], setting_timeline_autoscroll)
		setting_timeline_compact = value_get_real(interfacemap[?"timeline_compact"], setting_timeline_compact)
		setting_timeline_select_jump = value_get_real(interfacemap[?"timeline_select_jump"], setting_timeline_select_jump)
		setting_z_is_up = value_get_real(interfacemap[?"z_is_up"], setting_z_is_up)
	
		toolbar_location = value_get_string(interfacemap[?"toolbar_location"], toolbar_location)
		toolbar_size = value_get_real(interfacemap[?"toolbar_size"], toolbar_size)

		panel_left_bottom.size = value_get_real(interfacemap[?"panel_left_bottom_size"], panel_left_bottom.size)
		panel_right_bottom.size = value_get_real(interfacemap[?"panel_right_bottom_size"], panel_right_bottom.size)
		panel_bottom.size = value_get_real(interfacemap[?"panel_bottom_size"], panel_bottom.size)
		panel_top.size = value_get_real(interfacemap[?"panel_top_size"], panel_top.size)
		panel_left_top.size = value_get_real(interfacemap[?"panel_left_top_size"], panel_left_top.size)
		panel_right_top.size = value_get_real(interfacemap[?"panel_right_top_size"], panel_right_top.size)

		var propertiespanel = value_get_real(interfacemap[?"properties_location"], properties.panel.num);
		var groundeditorpanel = value_get_real(interfacemap[?"ground_editor_location"], ground_editor.panel.num);
		var templateeditorpanel = value_get_real(interfacemap[?"template_editor_location"], template_editor.panel.num);
		var timelinepanel = value_get_real(interfacemap[?"timeline_location"], timeline.panel.num);
		var timelineeditorpanel = value_get_real(interfacemap[?"timeline_editor_location"], timeline_editor.panel.num);
		var frameeditorpanel = value_get_real(interfacemap[?"frame_editor_location"], frame_editor.panel.num);
		var settingspanel = value_get_real(interfacemap[?"settings_location"], settings.panel.num);

		panel_tab_list_remove(panel_right_top, properties)
		panel_tab_list_add(panel_list[|propertiespanel], 0, properties)
	
		ground_editor.panel = panel_list[|groundeditorpanel]
		template_editor.panel = panel_list[|templateeditorpanel]
	
		panel_tab_list_remove(panel_bottom, timeline)
		panel_tab_list_add(panel_list[|timelinepanel], 0, timeline)
	
		timeline_editor.panel = panel_list[|timelineeditorpanel]
		frame_editor.panel = panel_list[|frameeditorpanel]
		settings.panel = panel_list[|settingspanel]
	
		view_split = value_get_real(interfacemap[?"view_split"], view_split)

		view_main.controls = value_get_real(interfacemap[?"view_main_controls"], view_main.controls)
		view_main.lights = value_get_real(interfacemap[?"view_main_lights"], view_main.lights)
		view_main.particles = value_get_real(interfacemap[?"view_main_particles"], view_main.particles)
		view_main.grid = value_get_real(interfacemap[?"view_main_grid"], view_main.grid)
		view_main.aspect_ratio = value_get_real(interfacemap[?"view_main_aspect_ratio"], view_main.aspect_ratio)
		view_main.location = value_get_string(interfacemap[?"view_main_location"], view_main.location)

		view_second.show = value_get_real(interfacemap[?"view_second_show"], view_second.show)
		view_second.controls = value_get_real(interfacemap[?"view_second_controls"], view_second.controls)
		view_second.lights = value_get_real(interfacemap[?"view_second_lights"], view_second.lights)
		view_second.particles = value_get_real(interfacemap[?"view_second_particles"], view_second.particles)
		view_second.grid = value_get_real(interfacemap[?"view_second_grid"], view_second.grid)
		view_second.aspect_ratio = value_get_real(interfacemap[?"view_second_aspect_ratio"], view_second.aspect_ratio)
		view_second.location = value_get_string(interfacemap[?"view_second_location"], view_second.location)
		view_second.width = value_get_real(interfacemap[?"view_second_width"], view_second.width)
		view_second.height = value_get_real(interfacemap[?"view_second_height"], view_second.height)

		frame_editor.color.advanced = value_get_real(interfacemap[?"frame_editor_color_advanced"], frame_editor.color.advanced)
	}
	
	// Controls
	var controlsmap = map[?"controls"];
	if (ds_map_valid(controlsmap))
	{
		setting_key_new = value_get_real(controlsmap[?"key_new"], setting_key_new)
		setting_key_new_control = value_get_real(controlsmap[?"key_new_control"], setting_key_new_control)
		setting_key_import_asset = value_get_real(controlsmap[?"key_import_asset"], setting_key_import_asset)
		setting_key_import_asset_control = value_get_real(controlsmap[?"key_import_asset_control"], setting_key_import_asset_control)
		setting_key_open = value_get_real(controlsmap[?"key_open"], setting_key_open)
		setting_key_open_control = value_get_real(controlsmap[?"key_open_control"], setting_key_open_control)
		setting_key_save = value_get_real(controlsmap[?"key_save"], setting_key_save)
		setting_key_save_control = value_get_real(controlsmap[?"key_save_control"], setting_key_save_control)
		setting_key_undo = value_get_real(controlsmap[?"key_undo"], setting_key_undo)
		setting_key_undo_control = value_get_real(controlsmap[?"key_undo_control"], setting_key_undo_control)
		setting_key_redo = value_get_real(controlsmap[?"key_redo"], setting_key_redo)
		setting_key_redo_control = value_get_real(controlsmap[?"key_redo_control"], setting_key_redo_control)
		setting_key_play = value_get_real(controlsmap[?"key_play"], setting_key_play)
		setting_key_play_control = value_get_real(controlsmap[?"key_play_control"], setting_key_play_control)
		setting_key_play_beginning = value_get_real(controlsmap[?"key_play_beginning"], setting_key_play_beginning)
		setting_key_play_beginning_control = value_get_real(controlsmap[?"key_play_beginning_control"], setting_key_play_beginning_control)
		setting_key_move_marker_right = value_get_real(controlsmap[?"key_move_marker_right"], setting_key_move_marker_right)
		setting_key_move_marker_right_control = value_get_real(controlsmap[?"key_move_marker_right_control"], setting_key_move_marker_right_control)
		setting_key_move_marker_left = value_get_real(controlsmap[?"key_move_marker_left"], setting_key_move_marker_left)
		setting_key_move_marker_left_control = value_get_real(controlsmap[?"key_move_marker_left_control"], setting_key_move_marker_left_control)
		setting_key_render = value_get_real(controlsmap[?"key_render"], setting_key_render)
		setting_key_render_control = value_get_real(controlsmap[?"key_render_control"], setting_key_render_control)
		setting_key_folder = value_get_real(controlsmap[?"key_folder"], setting_key_folder)
		setting_key_folder_control = value_get_real(controlsmap[?"key_folder_control"], setting_key_folder_control)
		setting_key_select_timelines = value_get_real(controlsmap[?"key_select_timelines"], setting_key_select_timelines)
		setting_key_select_timelines_control = value_get_real(controlsmap[?"key_select_timelines_control"], setting_key_select_timelines_control)
		setting_key_duplicate_timelines = value_get_real(controlsmap[?"key_duplicate_timelines"], setting_key_duplicate_timelines)
		setting_key_duplicate_timelines_control = value_get_real(controlsmap[?"key_duplicate_timelines_control"], setting_key_duplicate_timelines_control)
		setting_key_remove_timelines = value_get_real(controlsmap[?"key_remove_timelines"], setting_key_remove_timelines)
		setting_key_remove_timelines_control = value_get_real(controlsmap[?"key_remove_timelines_control"], setting_key_remove_timelines_control)
		setting_key_copy_keyframes = value_get_real(controlsmap[?"key_copy_keyframes"], setting_key_copy_keyframes)
		setting_key_copy_keyframes_control = value_get_real(controlsmap[?"key_copy_keyframes_control"], setting_key_copy_keyframes_control)
		setting_key_cut_keyframes = value_get_real(controlsmap[?"key_cut_keyframes"], setting_key_cut_keyframes)
		setting_key_cut_keyframes_control = value_get_real(controlsmap[?"key_cut_keyframes_control"], setting_key_cut_keyframes_control)
		setting_key_paste_keyframes = value_get_real(controlsmap[?"key_paste_keyframes"], setting_key_paste_keyframes)
		setting_key_paste_keyframes_control = value_get_real(controlsmap[?"key_paste_keyframes_control"], setting_key_paste_keyframes_control)
		setting_key_remove_keyframes = value_get_real(controlsmap[?"key_remove_keyframes"], setting_key_remove_keyframes)
		setting_key_remove_keyframes_control = value_get_real(controlsmap[?"key_remove_keyframes_control"], setting_key_remove_keyframes_control)
		setting_key_spawn_particles = value_get_real(controlsmap[?"key_spawn_particles"], setting_key_spawn_particles)
		setting_key_spawn_particles_control = value_get_real(controlsmap[?"key_spawn_particles_control"], setting_key_spawn_particles_control)
		setting_key_clear_particles = value_get_real(controlsmap[?"key_clear_particles"], setting_key_clear_particles)
		setting_key_clear_particles_control = value_get_real(controlsmap[?"key_clear_particles_control"], setting_key_clear_particles_control)

		setting_key_forward = value_get_real(controlsmap[?"key_forward"], setting_key_forward)
		setting_key_back = value_get_real(controlsmap[?"key_back"], setting_key_back)
		setting_key_left = value_get_real(controlsmap[?"key_left"], setting_key_left)
		setting_key_right = value_get_real(controlsmap[?"key_right"], setting_key_right)
		setting_key_ascend = value_get_real(controlsmap[?"key_ascend"], setting_key_ascend)
		setting_key_descend = value_get_real(controlsmap[?"key_descend"], setting_key_descend)
		setting_key_roll_forward = value_get_real(controlsmap[?"key_roll_forward"], setting_key_roll_forward)
		setting_key_roll_back = value_get_real(controlsmap[?"key_roll_back"], setting_key_roll_back)
		setting_key_roll_reset = value_get_real(controlsmap[?"key_roll_reset"], setting_key_roll_reset)
		setting_key_reset = value_get_real(controlsmap[?"key_reset"], setting_key_reset)
		setting_key_fast = value_get_real(controlsmap[?"key_fast"], setting_key_fast)
		setting_key_slow = value_get_real(controlsmap[?"key_slow"], setting_key_slow)
		setting_move_speed = value_get_real(controlsmap[?"move_speed"], setting_move_speed)
		setting_look_sensitivity = value_get_real(controlsmap[?"look_sensitivity"], setting_look_sensitivity)
		setting_fast_modifier = value_get_real(controlsmap[?"fast_modifier"], setting_fast_modifier)
		setting_slow_modifier = value_get_real(controlsmap[?"slow_modifier"], setting_slow_modifier)
	}
	
	// Graphics
	var graphicsmap = map[?"graphics"];
	if (ds_map_valid(graphicsmap))
	{
		setting_bend_round_default = value_get_real(graphicsmap[?"bend_round_default"], setting_bend_round_default)
		setting_bend_detail = value_get_real(graphicsmap[?"bend_detail"], setting_bend_detail)
		setting_bend_scale = value_get_real(graphicsmap[?"bend_scale"], setting_bend_scale)
		setting_schematic_remove_edges = value_get_real(graphicsmap[?"schematic_remove_edges"], setting_schematic_remove_edges)
		setting_liquid_animation = value_get_real(graphicsmap[?"liquid_animation"], setting_liquid_animation)
		setting_texture_filtering = value_get_real(graphicsmap[?"texture_filtering"], setting_texture_filtering)
		setting_transparent_texture_filtering = value_get_real(graphicsmap[?"transparent_texture_filtering"], setting_transparent_texture_filtering)
		setting_texture_filtering_level = value_get_real(graphicsmap[?"texture_filtering_level"], setting_texture_filtering_level)
		setting_block_brightness = value_get_real(graphicsmap[?"block_brightness"], setting_block_brightness)
	}
	
	// Render
	var rendermap = map[?"render"];
	if (ds_map_valid(rendermap))
	{
		setting_render_ssao = value_get_real(rendermap[?"render_ssao"], setting_render_ssao)
		setting_render_ssao_radius = value_get_real(rendermap[?"render_ssao_radius"], setting_render_ssao_radius)
		setting_render_ssao_power = value_get_real(rendermap[?"render_ssao_power"], setting_render_ssao_power)
		setting_render_ssao_blur_passes = value_get_real(rendermap[?"render_ssao_blur_passes"], setting_render_ssao_blur_passes)
		setting_render_ssao_color = value_get_color(rendermap[?"render_ssao_color"], setting_render_ssao_color)

		setting_render_shadows = value_get_real(rendermap[?"render_shadows"], setting_render_shadows)
		setting_render_shadows_sun_buffer_size = value_get_real(rendermap[?"render_shadows_sun_buffer_size"], setting_render_shadows_sun_buffer_size)
		setting_render_shadows_spot_buffer_size = value_get_real(rendermap[?"render_shadows_spot_buffer_size"], setting_render_shadows_spot_buffer_size)
		setting_render_setting_render_shadows_point_buffer_sizessao = value_get_real(rendermap[?"render_shadows_point_buffer_size"], setting_render_shadows_point_buffer_size)
		setting_render_shadows_blur_quality = value_get_real(rendermap[?"render_shadows_blur_quality"], setting_render_shadows_blur_quality)
		setting_render_shadows_blur_size = value_get_real(rendermap[?"render_shadows_blur_size"], setting_render_shadows_blur_size)

		setting_render_dof = value_get_real(rendermap[?"render_dof"], setting_render_dof)
		setting_render_dof_blur_size = value_get_real(rendermap[?"render_dof_blur_size"], setting_render_dof_blur_size)

		setting_render_aa = value_get_real(rendermap[?"render_aa"], setting_render_aa)
		setting_render_aa_power = value_get_real(rendermap[?"render_aa_power"], setting_render_aa_power)

		setting_render_watermark = value_get_real(rendermap[?"render_watermark"], setting_render_watermark)

		popup_exportmovie.format = value_get_string(rendermap[?"exportmovie_format"], popup_exportmovie.format)
		popup_exportmovie.frame_rate = value_get_real(rendermap[?"exportmovie_frame_rate"], popup_exportmovie.frame_rate)
		popup_exportmovie.bit_rate = value_get_real(rendermap[?"exportmovie_bit_rate"], popup_exportmovie.bit_rate)
		popup_exportmovie.include_audio = value_get_real(rendermap[?"exportmovie_include_audio"], popup_exportmovie.include_audio)
		popup_exportmovie.remove_background = value_get_real(rendermap[?"exportmovie_remove_background"], popup_exportmovie.remove_background)
		popup_exportmovie.include_hidden = value_get_real(rendermap[?"exportmovie_include_hidden"], popup_exportmovie.include_hidden)
		popup_exportmovie.high_quality = value_get_real(rendermap[?"exportmovie_high_quality"], popup_exportmovie.high_quality)

		popup_exportimage.remove_background = value_get_real(rendermap[?"exportimage_remove_background"], popup_exportimage.remove_background)
		popup_exportimage.include_hidden = value_get_real(rendermap[?"exportimage_include_hidden"], popup_exportimage.include_hidden)
		popup_exportimage.high_quality = value_get_real(rendermap[?"exportimage_high_quality"], popup_exportimage.high_quality)
	}
}

// Legacy
else
{
	settings_load_legacy(fn)
	settings_load_legacy_recent(data_directory + "recent.file")
}