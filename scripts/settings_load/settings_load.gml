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
	var json, map;
	json = file_text_contents(fn)
	map = json_decode(json)
	if (map < 0)
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
				filename = json_read_string(curfile[?"filename"])
				name = json_read_string(curfile[?"name"])
				author = json_read_string(curfile[?"author"])
				description = json_read_string(curfile[?"description"])
				date = json_read_real(curfile[?"date"])
		
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
		room_speed = json_read_real(programmap[?"fps"], room_speed)
		if (!dev_mode)
			setting_project_folder = json_read_string(programmap[?"project_folder"], setting_project_folder)
		setting_backup = json_read_real(programmap[?"backup"], setting_backup)
		setting_backup_time = json_read_real(programmap[?"backup_time"], setting_backup_time)
		setting_backup_amount = json_read_real(programmap[?"backup_amount"], setting_backup_amount)
		setting_spawn_objects = json_read_real(programmap[?"spawn_objects"], setting_spawn_objects)
		setting_spawn_cameras = json_read_real(programmap[?"spawn_cameras"], setting_spawn_cameras)
	}
	
	// Interface
	var interfacemap = map[?"interface"];
	if (ds_map_valid(interfacemap))
	{
		setting_tip_show = json_read_real(interfacemap[?"tip_show"], setting_tip_show)
		setting_tip_delay = json_read_real(interfacemap[?"tip_delay"], setting_tip_delay)

		setting_view_grid_size_hor = json_read_real(interfacemap[?"view_grid_size_hor"], setting_view_grid_size_hor)
		setting_view_grid_size_ver = json_read_real(interfacemap[?"view_grid_size_ver"], setting_view_grid_size_ver)
		setting_view_real_time_render = json_read_real(interfacemap[?"view_real_time_render"], setting_view_real_time_render)
		setting_view_real_time_render_time = json_read_real(interfacemap[?"view_real_time_render_time"], setting_view_real_time_render_time)

		setting_font_filename = json_read_string(interfacemap[?"font_filename"], setting_font_filename)
		setting_language_filename = json_read_string(interfacemap[?"language_filename"], setting_language_filename)
		
		settings_load_colors(interfacemap[?"colors"])

		setting_timeline_autoscroll = json_read_real(interfacemap[?"timeline_autoscroll"], setting_timeline_autoscroll)
		setting_timeline_compact = json_read_real(interfacemap[?"timeline_compact"], setting_timeline_compact)
		setting_timeline_select_jump = json_read_real(interfacemap[?"timeline_select_jump"], setting_timeline_select_jump)
		setting_z_is_up = json_read_real(interfacemap[?"z_is_up"], setting_z_is_up)
	
		toolbar_location = json_read_string(interfacemap[?"toolbar_location"], toolbar_location)
		toolbar_size = json_read_real(interfacemap[?"toolbar_size"], toolbar_size)

		panel_left_bottom.size = json_read_real(interfacemap[?"panel_left_bottom_size"], panel_left_bottom.size)
		panel_right_bottom.size = json_read_real(interfacemap[?"panel_right_bottom_size"], panel_right_bottom.size)
		panel_bottom.size = json_read_real(interfacemap[?"panel_bottom_size"], panel_bottom.size)
		panel_top.size = json_read_real(interfacemap[?"panel_top_size"], panel_top.size)
		panel_left_top.size = json_read_real(interfacemap[?"panel_left_top_size"], panel_left_top.size)
		panel_right_top.size = json_read_real(interfacemap[?"panel_right_top_size"], panel_right_top.size)

		var propertiespanel = json_read_real(interfacemap[?"properties_location"], properties.panel.num);
		var groundeditorpanel = json_read_real(interfacemap[?"ground_editor_location"], ground_editor.panel.num);
		var templateeditorpanel = json_read_real(interfacemap[?"template_editor_location"], template_editor.panel.num);
		var timelinepanel = json_read_real(interfacemap[?"timeline_location"], timeline.panel.num);
		var timelineeditorpanel = json_read_real(interfacemap[?"timeline_editor_location"], timeline_editor.panel.num);
		var frameeditorpanel = json_read_real(interfacemap[?"frame_editor_location"], frame_editor.panel.num);
		var settingspanel = json_read_real(interfacemap[?"settings_location"], settings.panel.num);

		panel_tab_list_remove(panel_right_top, properties)
		panel_tab_list_add(panel_list[|propertiespanel], 0, properties)
	
		ground_editor.panel = panel_list[|groundeditorpanel]
		template_editor.panel = panel_list[|templateeditorpanel]
	
		panel_tab_list_remove(panel_bottom, timeline)
		panel_tab_list_add(panel_list[|timelinepanel], 0, timeline)
	
		timeline_editor.panel = panel_list[|timelineeditorpanel]
		frame_editor.panel = panel_list[|frameeditorpanel]
		settings.panel = panel_list[|settingspanel]
	
		view_split = json_read_real(interfacemap[?"view_split"], view_split)

		view_main.controls = json_read_real(interfacemap[?"view_main_controls"], view_main.controls)
		view_main.lights = json_read_real(interfacemap[?"view_main_lights"], view_main.lights)
		view_main.particles = json_read_real(interfacemap[?"view_main_particles"], view_main.particles)
		view_main.grid = json_read_real(interfacemap[?"view_main_grid"], view_main.grid)
		view_main.aspect_ratio = json_read_real(interfacemap[?"view_main_aspect_ratio"], view_main.aspect_ratio)
		view_main.location = json_read_string(interfacemap[?"view_main_location"], view_main.location)

		view_second.show = json_read_real(interfacemap[?"view_second_show"], view_second.show)
		view_second.controls = json_read_real(interfacemap[?"view_second_controls"], view_second.controls)
		view_second.lights = json_read_real(interfacemap[?"view_second_lights"], view_second.lights)
		view_second.particles = json_read_real(interfacemap[?"view_second_particles"], view_second.particles)
		view_second.grid = json_read_real(interfacemap[?"view_second_grid"], view_second.grid)
		view_second.aspect_ratio = json_read_real(interfacemap[?"view_second_aspect_ratio"], view_second.aspect_ratio)
		view_second.location = json_read_string(interfacemap[?"view_second_location"], view_second.location)
		view_second.width = json_read_real(interfacemap[?"view_second_width"], view_second.width)
		view_second.height = json_read_real(interfacemap[?"view_second_height"], view_second.height)

		frame_editor.color.advanced = json_read_real(interfacemap[?"frame_editor_color_advanced"], frame_editor.color.advanced)
	}
	
	// Controls
	var controlsmap = map[?"controls"];
	if (ds_map_valid(controlsmap))
	{
	    setting_key_new = json_read_real(controlsmap[?"key_new"], setting_key_new)
		setting_key_new_control = json_read_real(controlsmap[?"key_new_control"], setting_key_new_control)
		setting_key_import_asset = json_read_real(controlsmap[?"key_import_asset"], setting_key_import_asset)
		setting_key_import_asset_control = json_read_real(controlsmap[?"key_import_asset_control"], setting_key_import_asset_control)
		setting_key_open = json_read_real(controlsmap[?"key_open"], setting_key_open)
		setting_key_open_control = json_read_real(controlsmap[?"key_open_control"], setting_key_open_control)
		setting_key_save = json_read_real(controlsmap[?"key_save"], setting_key_save)
		setting_key_save_control = json_read_real(controlsmap[?"key_save_control"], setting_key_save_control)
		setting_key_undo = json_read_real(controlsmap[?"key_undo"], setting_key_undo)
		setting_key_undo_control = json_read_real(controlsmap[?"key_undo_control"], setting_key_undo_control)
		setting_key_redo = json_read_real(controlsmap[?"key_redo"], setting_key_redo)
		setting_key_redo_control = json_read_real(controlsmap[?"key_redo_control"], setting_key_redo_control)
		setting_key_play = json_read_real(controlsmap[?"key_play"], setting_key_play)
		setting_key_play_control = json_read_real(controlsmap[?"key_play_control"], setting_key_play_control)
		setting_key_play_beginning = json_read_real(controlsmap[?"key_play_beginning"], setting_key_play_beginning)
		setting_key_play_beginning_control = json_read_real(controlsmap[?"key_play_beginning_control"], setting_key_play_beginning_control)
		setting_key_move_marker_right = json_read_real(controlsmap[?"key_move_marker_right"], setting_key_move_marker_right)
		setting_key_move_marker_right_control = json_read_real(controlsmap[?"key_move_marker_right_control"], setting_key_move_marker_right_control)
		setting_key_move_marker_left = json_read_real(controlsmap[?"key_move_marker_left"], setting_key_move_marker_left)
		setting_key_move_marker_left_control = json_read_real(controlsmap[?"key_move_marker_left_control"], setting_key_move_marker_left_control)
		setting_key_render = json_read_real(controlsmap[?"key_render"], setting_key_render)
		setting_key_render_control = json_read_real(controlsmap[?"key_render_control"], setting_key_render_control)
		setting_key_folder = json_read_real(controlsmap[?"key_folder"], setting_key_folder)
		setting_key_folder_control = json_read_real(controlsmap[?"key_folder_control"], setting_key_folder_control)
		setting_key_select_timelines = json_read_real(controlsmap[?"key_select_timelines"], setting_key_select_timelines)
		setting_key_select_timelines_control = json_read_real(controlsmap[?"key_select_timelines_control"], setting_key_select_timelines_control)
		setting_key_duplicate_timelines = json_read_real(controlsmap[?"key_duplicate_timelines"], setting_key_duplicate_timelines)
		setting_key_duplicate_timelines_control = json_read_real(controlsmap[?"key_duplicate_timelines_control"], setting_key_duplicate_timelines_control)
		setting_key_remove_timelines = json_read_real(controlsmap[?"key_remove_timelines"], setting_key_remove_timelines)
		setting_key_remove_timelines_control = json_read_real(controlsmap[?"key_remove_timelines_control"], setting_key_remove_timelines_control)
		setting_key_copy_keyframes = json_read_real(controlsmap[?"key_copy_keyframes"], setting_key_copy_keyframes)
		setting_key_copy_keyframes_control = json_read_real(controlsmap[?"key_copy_keyframes_control"], setting_key_copy_keyframes_control)
		setting_key_cut_keyframes = json_read_real(controlsmap[?"key_cut_keyframes"], setting_key_cut_keyframes)
		setting_key_cut_keyframes_control = json_read_real(controlsmap[?"key_cut_keyframes_control"], setting_key_cut_keyframes_control)
		setting_key_paste_keyframes = json_read_real(controlsmap[?"key_paste_keyframes"], setting_key_paste_keyframes)
		setting_key_paste_keyframes_control = json_read_real(controlsmap[?"key_paste_keyframes_control"], setting_key_paste_keyframes_control)
		setting_key_remove_keyframes = json_read_real(controlsmap[?"key_remove_keyframes"], setting_key_remove_keyframes)
		setting_key_remove_keyframes_control = json_read_real(controlsmap[?"key_remove_keyframes_control"], setting_key_remove_keyframes_control)
		setting_key_spawn_particles = json_read_real(controlsmap[?"key_spawn_particles"], setting_key_spawn_particles)
		setting_key_spawn_particles_control = json_read_real(controlsmap[?"key_spawn_particles_control"], setting_key_spawn_particles_control)
		setting_key_clear_particles = json_read_real(controlsmap[?"key_clear_particles"], setting_key_clear_particles)
		setting_key_clear_particles_control = json_read_real(controlsmap[?"key_clear_particles_control"], setting_key_clear_particles_control)

		setting_key_forward = json_read_real(controlsmap[?"key_forward"], setting_key_forward)
		setting_key_back = json_read_real(controlsmap[?"key_back"], setting_key_back)
		setting_key_left = json_read_real(controlsmap[?"key_left"], setting_key_left)
		setting_key_right = json_read_real(controlsmap[?"key_right"], setting_key_right)
		setting_key_ascend = json_read_real(controlsmap[?"key_ascend"], setting_key_ascend)
		setting_key_descend = json_read_real(controlsmap[?"key_descend"], setting_key_descend)
		setting_key_roll_forward = json_read_real(controlsmap[?"key_roll_forward"], setting_key_roll_forward)
		setting_key_roll_back = json_read_real(controlsmap[?"key_roll_back"], setting_key_roll_back)
		setting_key_roll_reset = json_read_real(controlsmap[?"key_roll_reset"], setting_key_roll_reset)
		setting_key_reset = json_read_real(controlsmap[?"key_reset"], setting_key_reset)
		setting_key_fast = json_read_real(controlsmap[?"key_fast"], setting_key_fast)
		setting_key_slow = json_read_real(controlsmap[?"key_slow"], setting_key_slow)
		setting_move_speed = json_read_real(controlsmap[?"move_speed"], setting_move_speed)
		setting_look_sensitivity = json_read_real(controlsmap[?"look_sensitivity"], setting_look_sensitivity)
		setting_fast_modifier = json_read_real(controlsmap[?"fast_modifier"], setting_fast_modifier)
		setting_slow_modifier = json_read_real(controlsmap[?"slow_modifier"], setting_slow_modifier)
	}
	
	// Graphics
	var graphicsmap = map[?"graphics"];
	if (ds_map_valid(graphicsmap))
	{
		setting_bend_round_default = json_read_real(graphicsmap[?"bend_round_default"], setting_bend_round_default)
		setting_bend_detail = json_read_real(graphicsmap[?"bend_detail"], setting_bend_detail)
		setting_bend_scale = json_read_real(graphicsmap[?"bend_scale"], setting_bend_scale)
		setting_schematic_remove_edges = json_read_real(graphicsmap[?"schematic_remove_edges"], setting_schematic_remove_edges)
		setting_liquid_animation = json_read_real(graphicsmap[?"liquid_animation"], setting_liquid_animation)
		setting_texture_filtering = json_read_real(graphicsmap[?"texture_filtering"], setting_texture_filtering)
		setting_transparent_texture_filtering = json_read_real(graphicsmap[?"transparent_texture_filtering"], setting_transparent_texture_filtering)
		setting_texture_filtering_level = json_read_real(graphicsmap[?"texture_filtering_level"], setting_texture_filtering_level)
		setting_block_brightness = json_read_real(graphicsmap[?"block_brightness"], setting_block_brightness)
	}
	
	// Render
	var rendermap = map[?"render"];
	if (ds_map_valid(rendermap))
	{
		setting_render_ssao = json_read_real(rendermap[?"render_ssao"], setting_render_ssao)
		setting_render_ssao_radius = json_read_real(rendermap[?"render_ssao_radius"], setting_render_ssao_radius)
		setting_render_ssao_power = json_read_real(rendermap[?"render_ssao_power"], setting_render_ssao_power)
		setting_render_ssao_blur_passes = json_read_real(rendermap[?"render_ssao_blur_passes"], setting_render_ssao_blur_passes)
		setting_render_ssao_color = json_read_color(rendermap[?"render_ssao_color"], setting_render_ssao_color)

		setting_render_shadows = json_read_real(rendermap[?"render_shadows"], setting_render_shadows)
		setting_render_shadows_sun_buffer_size = json_read_real(rendermap[?"render_shadows_sun_buffer_size"], setting_render_shadows_sun_buffer_size)
		setting_render_shadows_spot_buffer_size = json_read_real(rendermap[?"render_shadows_spot_buffer_size"], setting_render_shadows_spot_buffer_size)
		setting_render_setting_render_shadows_point_buffer_sizessao = json_read_real(rendermap[?"render_shadows_point_buffer_size"], setting_render_shadows_point_buffer_size)
		setting_render_shadows_blur_quality = json_read_real(rendermap[?"render_shadows_blur_quality"], setting_render_shadows_blur_quality)
		setting_render_shadows_blur_size = json_read_real(rendermap[?"render_shadows_blur_size"], setting_render_shadows_blur_size)

		setting_render_dof = json_read_real(rendermap[?"render_dof"], setting_render_dof)
		setting_render_dof_blur_size = json_read_real(rendermap[?"render_dof_blur_size"], setting_render_dof_blur_size)

		setting_render_aa = json_read_real(rendermap[?"render_aa"], setting_render_aa)
		setting_render_aa_power = json_read_real(rendermap[?"render_aa_power"], setting_render_aa_power)

		setting_render_watermark = json_read_real(rendermap[?"render_watermark"], setting_render_watermark)

		popup_exportmovie.format = json_read_string(rendermap[?"exportmovie_format"], popup_exportmovie.format)
		popup_exportmovie.frame_rate = json_read_real(rendermap[?"exportmovie_frame_rate"], popup_exportmovie.frame_rate)
		popup_exportmovie.bit_rate = json_read_real(rendermap[?"exportmovie_bit_rate"], popup_exportmovie.bit_rate)
		popup_exportmovie.include_audio = json_read_real(rendermap[?"exportmovie_include_audio"], popup_exportmovie.include_audio)
		popup_exportmovie.remove_background = json_read_real(rendermap[?"exportmovie_remove_background"], popup_exportmovie.remove_background)
		popup_exportmovie.include_hidden = json_read_real(rendermap[?"exportmovie_include_hidden"], popup_exportmovie.include_hidden)
		popup_exportmovie.high_quality = json_read_real(rendermap[?"exportmovie_high_quality"], popup_exportmovie.high_quality)

		popup_exportimage.remove_background = json_read_real(rendermap[?"exportimage_remove_background"], popup_exportimage.remove_background)
		popup_exportimage.include_hidden = json_read_real(rendermap[?"exportimage_include_hidden"], popup_exportimage.include_hidden)
		popup_exportimage.high_quality = json_read_real(rendermap[?"exportimage_high_quality"], popup_exportimage.high_quality)
	}
}

// Legacy
else
{
	settings_load_legacy(fn)
	settings_load_legacy_recent(data_directory + "recent.file")
}