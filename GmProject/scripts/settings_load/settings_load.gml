/// settings_load()
/// @desc Formats:
///			100 DEMO 4 = Initial
///			100 DEMO 5 = added spawn objects and camera
///			100 = added undo/redo shortcuts, project folder, ssao, shadows, dof, aa, grid size, even more shortcuts, panels, tabs, views, z is up, fps
///			103 = compact timeline, jump to select, real time render
///			106 = wave animation, exportmovie/image settings
///			106_2 = block emissive
///			106_3 = remove camera buffer size
///			110 = remade in JSON, texture filtering level

function settings_load()
{
	var fn = settings_file;
	
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
		
		// Assets
		var assetsmap = map[?"assets"];
		if (ds_map_valid(assetsmap))
		{
			setting_minecraft_assets_version = value_get_string(assetsmap[?"version"])
			
			var newmap = assetsmap[?"new"];
			if (ds_map_valid(newmap))
			{
				setting_minecraft_assets_new_version = value_get_string(newmap[?"version"])
				setting_minecraft_assets_new_format = value_get_real(newmap[?"format"])
				setting_minecraft_assets_new_changes = value_get_string(newmap[?"changes"])
				setting_minecraft_assets_new_image = value_get_string(newmap[?"image"])
			}
		}
		
		// Closed alerts
		var toastslist = map[?"closed_toasts"];
		if (ds_list_valid(toastslist))
			ds_list_copy(closed_toast_list, toastslist)
		
		// Program
		var programmap = map[?"program"];
		if (ds_map_valid(programmap))
		{
			setting_advanced_mode = value_get_real(programmap[?"advanced_mode"], setting_advanced_mode)
			
			// No interface setting, but custom fps can be loaded from file
			room_speed = value_get_real(programmap[?"fps"], room_speed)
			
			if (!dev_mode)
				setting_project_folder = value_get_string(programmap[?"project_folder"], setting_project_folder)
			if (!directory_exists_lib(setting_project_folder))
				setting_project_folder = projects_directory
			
			setting_backup = value_get_real(programmap[?"backup"], setting_backup)
			setting_backup_time = value_get_real(programmap[?"backup_time"], setting_backup_time)
			setting_backup_amount = value_get_real(programmap[?"backup_amount"], setting_backup_amount)
			setting_spawn_cameras = value_get_real(programmap[?"spawn_cameras"], setting_spawn_cameras)
			setting_unlimited_values = value_get_real(programmap[?"unlimited_values"], setting_unlimited_values)
			
			setting_watermark_custom = value_get_real(programmap[?"watermark_custom"], setting_watermark_custom)
			setting_watermark_fn = value_get_string(programmap[?"watermark_fn"], setting_watermark_fn)
			setting_watermark_halign = value_get_string(programmap[?"watermark_halign"], setting_watermark_halign)
			setting_watermark_valign = value_get_string(programmap[?"watermark_valign"], setting_watermark_valign)
			setting_watermark_padding = value_get_real(programmap[?"watermark_padding"], setting_watermark_padding)
			setting_watermark_scale = value_get_real(programmap[?"watermark_scale"], setting_watermark_scale)
			setting_watermark_opacity = value_get_real(programmap[?"watermark_opacity"], setting_watermark_opacity)
			
			if (setting_watermark_fn != "")
				setting_watermark_image = texture_create(setting_watermark_fn)
		}
		
		// Interface
		var interfacemap = map[?"interface"];
		if (ds_map_valid(interfacemap))
		{
			setting_language_filename = value_get_string(interfacemap[?"language_filename"], setting_language_filename)
			if (!file_exists_lib(setting_language_filename))
				setting_language_filename = language_file
			
			if (setting_language_filename != language_file)
				language_load(setting_language_filename, language_map)
			
			var themename = theme_light.name;
			themename = value_get_string(interfacemap[?"theme"], themename)
			
			with (obj_theme)
			{
				if (themename = name)
				{
					app.setting_theme = id
					break
				}
			}
			
			setting_accent = value_get_real(interfacemap[?"accent"], setting_accent)
			setting_accent_custom = value_get_color(interfacemap[?"accent_custom"], setting_accent_custom)
			
			setting_timeline_autoscroll = value_get_real(interfacemap[?"timeline_autoscroll"], setting_timeline_autoscroll)
			setting_timeline_show_markers = value_get_real(interfacemap[?"timeline_show_markers"], setting_timeline_show_markers)
			setting_interface_compact = value_get_real(interfacemap[?"interface_compact"], setting_interface_compact)
			setting_timeline_compact = value_get_real(interfacemap[?"timeline_compact"], setting_timeline_compact)
			setting_reduced_motion = value_get_real(interfacemap[?"reduced_motion"], setting_reduced_motion)
			setting_timeline_select_jump = value_get_real(interfacemap[?"timeline_select_jump"], setting_timeline_select_jump)
			setting_timeline_hide_ghosts = value_get_real(interfacemap[?"timeline_hide_ghosts"], setting_timeline_hide_ghosts)
			setting_timeline_frame_snap = value_get_real(interfacemap[?"timeline_frame_snap"], setting_timeline_frame_snap)
			setting_z_is_up = value_get_real(interfacemap[?"z_is_up"], setting_z_is_up)
			setting_search_variants = value_get_real(interfacemap[?"search_variants"], setting_search_variants)
			setting_show_shortcuts_bar = value_get_real(interfacemap[?"show_shortcuts_bar"], setting_show_shortcuts_bar)
			setting_gizmos_face_camera = value_get_real(interfacemap[?"gizmos_face_camera"], setting_gizmos_face_camera)
			setting_fade_gizmos = value_get_real(interfacemap[?"fade_gizmos"], setting_fade_gizmos)
			setting_camera_lock_mouse = value_get_real(interfacemap[?"camera_lock_mouse"], setting_camera_lock_mouse)
			window_mouse_set_permission(setting_camera_lock_mouse)
			setting_place_new = value_get_real(interfacemap[?"place_new"], setting_place_new)
			setting_interface_scale_auto = value_get_real(interfacemap[?"scale_auto"], setting_interface_scale_auto)
			if (setting_interface_scale_auto)
				setting_interface_scale = interface_scale_default_get()
			else
				setting_interface_scale = value_get_real(interfacemap[?"scale"], setting_interface_scale)
			interface_scale_set(setting_interface_scale)
			
			setting_separate_tool_modes = value_get_real(interfacemap[?"separate_tool_modes"], setting_separate_tool_modes)
			if (setting_separate_tool_modes)
			{
				action_tools_disable_all()
				setting_tool_select = true
			}
			
			setting_panel_left_bottom_size = value_get_real(interfacemap[?"panel_left_bottom_size"], setting_panel_left_bottom_size)
			setting_panel_right_bottom_size = value_get_real(interfacemap[?"panel_right_bottom_size"], setting_panel_right_bottom_size)
			setting_panel_bottom_size = value_get_real(interfacemap[?"panel_bottom_size"], setting_panel_bottom_size)
			setting_panel_top_size = value_get_real(interfacemap[?"panel_top_size"], setting_panel_top_size)
			setting_panel_left_top_size = value_get_real(interfacemap[?"panel_left_top_size"], setting_panel_left_top_size)
			setting_panel_right_top_size = value_get_real(interfacemap[?"panel_right_top_size"], setting_panel_right_top_size)
			
			setting_properties_location = value_get_string(interfacemap[?"properties_location"], setting_properties_location)
			setting_ground_editor_location = value_get_string(interfacemap[?"ground_editor_location"], setting_ground_editor_location)
			setting_template_editor_location = value_get_string(interfacemap[?"template_editor_location"], setting_template_editor_location)
			setting_timeline_editor_location = value_get_string(interfacemap[?"timeline_editor_location"], setting_timeline_editor_location)
			setting_frame_editor_location = value_get_string(interfacemap[?"frame_editor_location"], setting_frame_editor_location)
			setting_settings_location = value_get_string(interfacemap[?"settings_location"], setting_settings_location)
			
			if (ds_map_valid(interfacemap[?"timeline_window"]))
				window_state_restore(e_window.TIMELINE, interfacemap[?"timeline_window"])
			
			setting_view_split = value_get_real(interfacemap[?"view_split"], setting_view_split)
			
			setting_view_main_overlays = value_get_real(interfacemap[?"view_main_overlays"], setting_view_main_overlays)
			setting_view_main_aspect_ratio = value_get_real(interfacemap[?"view_main_aspect_ratio"], setting_view_main_aspect_ratio)
			setting_view_main_grid = value_get_real(interfacemap[?"view_main_grid"], setting_view_main_grid)
			setting_view_main_gizmos = value_get_real(interfacemap[?"view_main_gizmos"], setting_view_main_gizmos)
			setting_view_main_fog = value_get_real(interfacemap[?"view_main_fog"], setting_view_main_fog)
			setting_view_main_effects = value_get_real(interfacemap[?"view_main_effects"], setting_view_main_effects)
			setting_view_main_particles = value_get_real(interfacemap[?"view_main_particles"], setting_view_main_particles)
			setting_view_main_location = value_get_string(interfacemap[?"view_main_location"], setting_view_main_location)
			
			setting_view_second_show = value_get_real(interfacemap[?"view_second_show"], setting_view_second_show)
			setting_view_second_overlays = value_get_real(interfacemap[?"view_second_overlays"], setting_view_second_overlays)
			setting_view_second_aspect_ratio = value_get_real(interfacemap[?"view_second_aspect_ratio"], setting_view_second_aspect_ratio)
			setting_view_second_grid = value_get_real(interfacemap[?"view_second_grid"], setting_view_second_grid)
			setting_view_second_gizmos = value_get_real(interfacemap[?"view_second_gizmos"], setting_view_second_gizmos)
			setting_view_second_fog = value_get_real(interfacemap[?"view_second_fog"], setting_view_second_fog)
			setting_view_second_effects = value_get_real(interfacemap[?"view_second_effects"], setting_view_second_effects)
			setting_view_second_particles = value_get_real(interfacemap[?"view_second_particles"], setting_view_second_particles)
			setting_view_second_location = value_get_string(interfacemap[?"view_second_location"], setting_view_second_location)
			setting_view_second_width = value_get_real(interfacemap[?"view_second_width"], setting_view_second_width)
			setting_view_second_height = value_get_real(interfacemap[?"view_second_height"], setting_view_second_height)
			
			if (ds_map_valid(interfacemap[?"view_second_window"]))
				window_state_restore(e_window.VIEW_SECOND, interfacemap[?"view_second_window"])
			
			setting_snap = value_get_real(interfacemap[?"snap"], setting_snap)
			setting_snap_absolute = value_get_real(interfacemap[?"snap_absolute"], setting_snap_absolute)
			setting_snap_size_position = value_get_real(interfacemap[?"snap_size_position"], setting_snap_size_position)
			setting_snap_size_rotation = value_get_real(interfacemap[?"snap_size_rotation"], setting_snap_size_rotation)
			setting_snap_size_scale = value_get_real(interfacemap[?"snap_size_scale"], setting_snap_size_scale)
			
			setting_modelbench_popup_hidden = value_get_real(interfacemap[?"modelbench_popup_hidden"], setting_modelbench_popup_hidden)
		}
		
		// Controls
		var controlsmap = map[?"controls"];
		if (ds_map_valid(controlsmap))
		{
			var obj;
			
			for (var i = 0; i < e_keybind.amount; i++)
			{
				obj = keybinds[i]
				obj.keybind = value_get_array(controlsmap[?obj.name], obj.keybind)
			}
			
			setting_move_speed = value_get_real(controlsmap[?"move_speed"], setting_move_speed)
			setting_look_sensitivity = value_get_real(controlsmap[?"look_sensitivity"], setting_look_sensitivity)
			setting_fast_modifier = value_get_real(controlsmap[?"fast_modifier"], setting_fast_modifier)
			setting_slow_modifier = value_get_real(controlsmap[?"slow_modifier"], setting_slow_modifier)
			
			keybinds_update_match()
		}
		
		// Export
		var exportmap = map[?"export"];
		if (ds_map_valid(exportmap))
		{
			setting_export_movie_format = value_get_string(map[?"exportmovie_format"], setting_export_movie_format)
			setting_export_movie_frame_rate = value_get_real(map[?"exportmovie_frame_rate"], setting_export_movie_frame_rate)
			setting_export_movie_framespersecond = value_get_real(map[?"exportmovie_framespersecond"], setting_export_movie_framespersecond)
			setting_export_movie_bit_rate = value_get_real(map[?"exportmovie_bit_rate"], setting_export_movie_bit_rate)
			setting_export_movie_include_audio = value_get_real(map[?"exportmovie_include_audio"], setting_export_movie_include_audio)
			setting_export_movie_remove_background = value_get_real(map[?"exportmovie_remove_background"], setting_export_movie_remove_background)
			setting_export_movie_include_hidden = value_get_real(map[?"exportmovie_remove_background"], setting_export_movie_include_hidden)
			setting_export_movie_high_quality = value_get_real(map[?"exportmovie_high_quality"], setting_export_movie_high_quality)
			setting_export_movie_watermark = value_get_real(map[?"exportmovie_watermark"], setting_export_movie_watermark)
			setting_export_image_remove_background = value_get_real(map[?"exportimage_remove_background"], setting_export_image_remove_background)
			setting_export_image_include_hidden = value_get_real(map[?"exportimage_include_hidden"], setting_export_image_include_hidden)
			setting_export_image_high_quality = value_get_real(map[?"exportimage_high_quality"], setting_export_image_high_quality)
			setting_export_image_watermark = value_get_real(map[?"exportimage_watermark"], setting_export_image_watermark)
		}
		
		// Collapsible content
		var collapsemap = map[?"collapse"];
		if (ds_map_valid(collapsemap))
		{
			var key = ds_map_find_first(collapse_map);
			
			while (!is_undefined(key))
			{
				collapse_map[?key] = value_get_real(collapsemap[?key], collapse_map[?key])
				key = ds_map_find_next(collapse_map, key)
			}
		}
		
		if (ds_map_valid(map[?"main_window"]))
		{
			var mainwindowmap = map[?"main_window"];
			var rectlist = mainwindowmap[?"rect"]
			setting_main_window_rect = array(rectlist[|0], rectlist[|1], rectlist[|2], rectlist[|3])
			setting_main_window_maximized = mainwindowmap[?"maximized"]
		}
		
		// World import
		var worldimportmap = map[?"world_import"]
		if (ds_map_valid(worldimportmap))
		{
			setting_world_import_filter_enabled = value_get_real(worldimportmap[?"filter_enabled"], setting_world_import_filter_enabled)
			setting_world_import_filter_mode = value_get_real(worldimportmap[?"filter_mode"], setting_world_import_filter_mode)
			ds_list_merge(setting_world_import_filter_list, worldimportmap[?"filter_list"])
			setting_world_import_unload_regions = value_get_real(worldimportmap[?"unload_regions"], setting_world_import_unload_regions)
		}
	}
	
	// Legacy
	else
	{
		settings_load_legacy(fn)
		settings_load_legacy_recent(data_directory + "recent.file")
	}
}
