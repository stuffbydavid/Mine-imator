/// settings_save()

function settings_save()
{
	log("Saving settings", settings_file)
	
	json_save_start(settings_file)
	json_save_object_start()
	json_save_var("format", settings_format)
	
	json_save_object_start("assets")
		
		json_save_var("version", setting_minecraft_assets_version)
		
		if (setting_minecraft_assets_new_version != "")
		{
			json_save_object_start("new")
				
				json_save_var("version", setting_minecraft_assets_new_version)
				json_save_var("format", setting_minecraft_assets_new_format)
				json_save_var("changes", json_string_encode(setting_minecraft_assets_new_changes))
				json_save_var("image", json_string_encode(setting_minecraft_assets_new_image))
				
			json_save_object_done()
		}
	
	json_save_object_done()
	
	json_save_array_start("recent_files")
		
		for (var i = 0; i < ds_list_size(recent_list); i++)
		{
			with (recent_list[|i])
			{
				json_save_object_start()
				json_save_var("filename", json_string_encode(filename))
				json_save_var("name", json_string_encode(name))
				json_save_var("author", json_string_encode(author))
				json_save_var("description", json_string_encode(description))
				json_save_object_done()
			}
		}
	
	json_save_array_done()
	
	json_save_array_start("closed_toasts")
	
		for (var i = 0; i < ds_list_size(closed_toast_list); i++)
			json_save_array_value(closed_toast_list[|i])
	
	json_save_array_done()
	
	json_save_object_start("program")
		
		if (setting_advanced_mode)
			json_save_var("advanced_mode", setting_advanced_mode)
		
		json_save_var("fps", room_speed)
		json_save_var("project_folder", json_string_encode(setting_project_folder))
		json_save_var_bool("backup", setting_backup)
		json_save_var("backup_time", setting_backup_time)
		json_save_var("backup_amount", setting_backup_amount)
		json_save_var_bool("spawn_cameras", setting_spawn_cameras)
		json_save_var_bool("unlimited_values", setting_unlimited_values)
		json_save_var_bool("scenery_remove_edges", setting_scenery_remove_edges)
		
		json_save_var_bool("watermark_custom", setting_watermark_custom)
		json_save_var("watermark_fn", setting_watermark_fn)
		json_save_var("watermark_halign", setting_watermark_halign)
		json_save_var("watermark_valign", setting_watermark_valign)
		json_save_var("watermark_padding", setting_watermark_padding)
		json_save_var("watermark_scale", setting_watermark_scale)
		json_save_var("watermark_opacity", setting_watermark_opacity)
		
	json_save_object_done()
	
	json_save_object_start("interface")
		
		json_save_var("language_filename", json_string_encode(setting_language_filename))
		
		json_save_var("theme", setting_theme.name)
		json_save_var("accent", setting_accent)
		json_save_var_color("accent_custom", setting_accent_custom)
		
		json_save_var_bool("timeline_autoscroll", setting_timeline_autoscroll)
		json_save_var_bool("timeline_show_markers", setting_timeline_show_markers)
		json_save_var_bool("interface_compact", setting_interface_compact)
		json_save_var_bool("timeline_compact", setting_timeline_compact)
		json_save_var_bool("reduced_motion", setting_reduced_motion)
		json_save_var_bool("timeline_select_jump", setting_timeline_select_jump)
		json_save_var_bool("timeline_hide_ghosts", setting_timeline_hide_ghosts)
		json_save_var_bool("timeline_frame_snap", setting_timeline_frame_snap)
		json_save_var_bool("z_is_up", setting_z_is_up)
		json_save_var_bool("search_variants", setting_search_variants)
		json_save_var_bool("separate_tool_modes", setting_separate_tool_modes)
		json_save_var_bool("show_shortcuts_bar", setting_show_shortcuts_bar)
		json_save_var_bool("gizmos_face_camera", setting_gizmos_face_camera)
		json_save_var_bool("fade_gizmos", setting_fade_gizmos)
		json_save_var_bool("camera_lock_mouse", setting_camera_lock_mouse)
		json_save_var_bool("place_new", setting_place_new)
		json_save_var("scale", setting_interface_scale)
		json_save_var_bool("scale_auto", setting_interface_scale_auto)
		
		json_save_var("panel_left_bottom_size", panel_map[?"left_secondary"].size)
		json_save_var("panel_right_bottom_size", panel_map[?"right_secondary"].size)
		json_save_var("panel_bottom_size", panel_map[?"bottom"].size)
		json_save_var("panel_top_size", panel_map[?"top"].size)
		json_save_var("panel_left_top_size", panel_map[?"left"].size)
		json_save_var("panel_right_top_size", panel_map[?"right"].size)
		
		json_save_var("properties_location", properties.panel.location)
		json_save_var("ground_editor_location", ground_editor.panel.location)
		json_save_var("template_editor_location", template_editor.panel.location)
		json_save_var("timeline_location", timeline.panel.location)
		json_save_var("timeline_editor_location", timeline_editor.panel.location)
		json_save_var("frame_editor_location", frame_editor.panel.location)
		json_save_var("settings_location", settings.panel.location)
		
		if (window_exists(e_window.TIMELINE))
		{
			json_save_object_start("timeline_window")
			window_state_save(e_window.TIMELINE)
			json_save_object_done()
		}
		
		json_save_var("view_split", view_split)
		
		json_save_var_bool("view_main_overlays", view_main.overlays)
		json_save_var_bool("view_main_aspect_ratio", view_main.aspect_ratio)
		json_save_var_bool("view_main_grid", view_main.grid)
		json_save_var_bool("view_main_gizmos", view_main.gizmos)
		json_save_var_bool("view_main_effects", view_main.effects)
		json_save_var_bool("view_main_particles", view_main.particles)
		json_save_var("view_main_location", view_main.location)
		
		json_save_var_bool("view_second_show", view_second.show)
		json_save_var_bool("view_second_overlays", view_second.overlays)
		json_save_var_bool("view_second_aspect_ratio", view_second.aspect_ratio)
		json_save_var_bool("view_second_grid", view_second.grid)
		json_save_var_bool("view_second_gizmos", view_second.gizmos)
		json_save_var_bool("view_second_effects", view_second.effects)
		json_save_var_bool("view_second_particles", view_second.particles)
		json_save_var("view_second_location", view_second.location)
		json_save_var("view_second_width", view_second.width)
		json_save_var("view_second_height", view_second.height)
		
		if (window_exists(e_window.VIEW_SECOND))
		{
			json_save_object_start("view_second_window")
			window_state_save(e_window.VIEW_SECOND)
			json_save_object_done()
		}
		
		json_save_var_bool("snap", setting_snap)
		json_save_var_bool("snap_absolute", setting_snap_absolute)
		json_save_var("snap_size_position", setting_snap_size_position)
		json_save_var("snap_size_rotation", setting_snap_size_rotation)
		json_save_var("snap_size_scale", setting_snap_size_scale)
		
		json_save_var_bool("modelbench_popup_hidden", popup_modelbench.hidden)
		
	json_save_object_done()
	
	json_save_object_start("controls")
		
		var obj;
		
		for (var i = 0; i < e_keybind.amount; i++)
		{
			obj = keybinds[i]
			json_save_var(obj.name, obj.keybind)
		}
		
		json_save_var("move_speed", setting_move_speed)
		json_save_var("look_sensitivity", setting_look_sensitivity)
		json_save_var("fast_modifier", setting_fast_modifier)
		json_save_var("slow_modifier", setting_slow_modifier)
		
	json_save_object_done()
	
	json_save_object_start("export")
		
		json_save_var("exportmovie_format", popup_exportmovie.format)
		json_save_var("exportmovie_frame_rate", popup_exportmovie.frame_rate)
		json_save_var("exportmovie_framespersecond", popup_exportmovie.framespersecond)
		json_save_var("exportmovie_bit_rate", popup_exportmovie.bit_rate)
		json_save_var_bool("exportmovie_include_audio", popup_exportmovie.include_audio)
		json_save_var_bool("exportmovie_remove_background", popup_exportmovie.remove_background)
		json_save_var_bool("exportmovie_include_hidden", popup_exportmovie.include_hidden)
		json_save_var_bool("exportmovie_high_quality", popup_exportmovie.high_quality)
		json_save_var_bool("exportmovie_watermark", popup_exportmovie.watermark)
		json_save_var_bool("exportimage_remove_background", popup_exportimage.remove_background)
		json_save_var_bool("exportimage_include_hidden", popup_exportimage.include_hidden)
		json_save_var_bool("exportimage_high_quality", popup_exportimage.high_quality)
		json_save_var_bool("exportimage_watermark", popup_exportimage.watermark)
		
	json_save_object_done()
	
	json_save_object_start("collapse")
		
		var key = ds_map_find_first(collapse_map);
		
		while (!is_undefined(key))
		{
			json_save_var_bool(key, collapse_map[?key])
			key = ds_map_find_next(collapse_map, key)
		}
		
	json_save_object_done()
	
	json_save_object_start("main_window")
		window_state_save(e_window.MAIN)
	json_save_object_done()
	
	json_save_object_start("world_import")
		json_save_var_bool("filter_enabled", setting_world_import_filter_enabled)
		json_save_var("filter_mode", setting_world_import_filter_mode)
		json_save_array_start("filter_list")
			for (var i = 0; i < ds_list_size(setting_world_import_filter_list); i++)
				json_save_array_value(setting_world_import_filter_list[|i])
		json_save_array_done()
		json_save_var_bool("unload_regions", setting_world_import_unload_regions)
		
	json_save_object_done()
	
	json_save_object_done()
	json_save_done()
	
	debug("Saved settings")
}
