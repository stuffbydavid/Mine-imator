/// settings_save()

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

	json_save_var("fps", room_speed)
	json_save_var("project_folder", json_string_encode(setting_project_folder))
	json_save_var_bool("backup", setting_backup)
	json_save_var("backup_time", setting_backup_time)
	json_save_var("backup_amount", setting_backup_amount)
	json_save_var_bool("spawn_objects", setting_spawn_objects)
	json_save_var_bool("spawn_cameras", setting_spawn_cameras)
	json_save_var_bool("unlimited_values", setting_unlimited_values)

json_save_object_done()

json_save_object_start("interface")

	json_save_var_bool("view_real_time_render", setting_view_real_time_render)
	json_save_var("view_real_time_render_time", setting_view_real_time_render_time)
	
	json_save_var("language_filename", json_string_encode(setting_language_filename))

	json_save_var("theme", setting_theme.name)
	json_save_var("accent", setting_accent)
	json_save_var_color("accent_custom", setting_accent_custom)

	json_save_var_bool("timeline_autoscroll", setting_timeline_autoscroll)
	json_save_var_bool("timeline_compact", setting_timeline_compact)
	json_save_var_bool("timeline_select_jump", setting_timeline_select_jump)
	json_save_var_bool("timeline_hide_ghosts", setting_timeline_hide_ghosts)
	json_save_var_bool("z_is_up", setting_z_is_up)
	json_save_var_bool("smooth_camera", setting_smooth_camera)
	json_save_var_bool("search_variants", setting_search_variants)
	json_save_var_bool("show_shortcuts_bar", setting_show_shortcuts_bar)
	
	json_save_var("toolbar_location", toolbar_location)
	json_save_var("toolbar_size", toolbar_size)

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
	json_save_var_bool("frame_editor_color_advanced", frame_editor.material.advanced)
	json_save_var("settings_location", settings.panel.location)

	json_save_var("view_split", view_split)

	json_save_var_bool("view_main_overlays", view_main.overlays)
	json_save_var_bool("view_main_aspect_ratio", view_main.aspect_ratio)
	json_save_var_bool("view_main_grid", view_main.grid)
	json_save_var_bool("view_main_gizmos", view_main.gizmos)
	json_save_var_bool("view_main_fog", view_main.fog)
	json_save_var_bool("view_main_effects", view_main.effects)
	json_save_var_bool("view_main_particles", view_main.particles)
	json_save_var("view_main_location", view_main.location)

	json_save_var_bool("view_second_show", view_second.show)
	json_save_var_bool("view_second_overlays", view_second.overlays)
	json_save_var_bool("view_second_aspect_ratio", view_second.aspect_ratio)
	json_save_var_bool("view_second_grid", view_second.grid)
	json_save_var_bool("view_second_gizmos", view_second.gizmos)
	json_save_var_bool("view_second_fog", view_second.fog)
	json_save_var_bool("view_second_effects", view_second.effects)
	json_save_var_bool("view_second_particles", view_second.particles)
	json_save_var("view_second_location", view_second.location)
	json_save_var("view_second_width", view_second.width)
	json_save_var("view_second_height", view_second.height)
	
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
		obj = keybinds_map[?i]
		json_save_var(obj.name, obj.keybind)
	}
	
	json_save_var("move_speed", setting_move_speed)
	json_save_var("look_sensitivity", setting_look_sensitivity)
	json_save_var("fast_modifier", setting_fast_modifier)
	json_save_var("slow_modifier", setting_slow_modifier)

json_save_object_done()

json_save_object_start("graphics")

	json_save_var("bend_style", setting_bend_style)
	json_save_var_bool("scenery_remove_edges", setting_scenery_remove_edges)
	json_save_var_bool("liquid_animation", setting_liquid_animation)
	json_save_var_bool("noisy_grass_water", setting_noisy_grass_water)
	json_save_var_bool("remove_waterlogged_water", setting_remove_waterlogged_water)
	json_save_var_bool("texture_filtering", setting_texture_filtering)
	json_save_var_bool("transparent_block_texture_filtering", setting_transparent_block_texture_filtering)
	json_save_var("texture_filtering_level", setting_texture_filtering_level)
	json_save_var("block_brightness", setting_block_brightness)
	json_save_var("block_glow_threshold", setting_block_glow_threshold)
	json_save_var_bool("block_glow", setting_block_glow)
	json_save_var_bool("light_bleeding", setting_light_bleeding)

json_save_object_done()

json_save_object_start("render")

	json_save_var("render_samples", setting_render_samples)
	json_save_var("render_dof_quality", setting_render_dof_quality)
	
	json_save_var_bool("render_ssao", setting_render_ssao)
	json_save_var("render_ssao_radius", setting_render_ssao_radius)
	json_save_var("render_ssao_power", setting_render_ssao_power)
	json_save_var("render_ssao_blur_passes", setting_render_ssao_blur_passes)
	json_save_var_color("render_ssao_color", setting_render_ssao_color)
	
	json_save_var_bool("render_shadows", setting_render_shadows)
	json_save_var("render_shadows_sun_buffer_size", setting_render_shadows_sun_buffer_size)
	json_save_var("render_shadows_spot_buffer_size", setting_render_shadows_spot_buffer_size)
	json_save_var("render_shadows_point_buffer_size", setting_render_shadows_point_buffer_size)
	json_save_var_bool("render_shadows_sun_colored", setting_render_shadows_sun_colored)
	
	json_save_var_bool("render_indirect", setting_render_indirect)
	json_save_var("render_indirect_blur_passes", setting_render_indirect_blur_passes)
	json_save_var("render_indirect_quality", setting_render_indirect_quality)
	json_save_var("render_indirect_strength", setting_render_indirect_strength)
	json_save_var("render_indirect_range", setting_render_indirect_range)
	json_save_var("render_indirect_scatter", setting_render_indirect_scatter)
	
	json_save_var_bool("render_glow", setting_render_glow)
	json_save_var("render_glow_radius", setting_render_glow_radius)
	json_save_var("render_glow_intensity", setting_render_glow_intensity)
	json_save_var_bool("render_glow_falloff", setting_render_glow_falloff)
	json_save_var("render_glow_falloff_radius", setting_render_glow_falloff_radius)
	json_save_var("render_glow_falloff_intensity", setting_render_glow_falloff_intensity)
	
	json_save_var_bool("render_aa", setting_render_aa)
	json_save_var("render_aa_power", setting_render_aa_power)
	
	json_save_var_bool("render_watermark", setting_render_watermark)
	json_save_var("render_watermark_filename", json_string_encode(setting_render_watermark_filename))
	json_save_var("render_watermark_anchor_x", setting_render_watermark_anchor_x)
	json_save_var("render_watermark_anchor_y", setting_render_watermark_anchor_y)
	json_save_var("render_watermark_scale", setting_render_watermark_scale)
	json_save_var("render_watermark_alpha", setting_render_watermark_alpha)
	
	json_save_var("exportmovie_format", popup_exportmovie.format)
	json_save_var("exportmovie_frame_rate", popup_exportmovie.frame_rate)
	json_save_var("exportmovie_bit_rate", popup_exportmovie.bit_rate)
	json_save_var_bool("exportmovie_include_audio", popup_exportmovie.include_audio)
	json_save_var_bool("exportmovie_remove_background", popup_exportmovie.remove_background)
	json_save_var_bool("exportmovie_include_hidden", popup_exportmovie.include_hidden)
	json_save_var_bool("exportmovie_high_quality", popup_exportmovie.high_quality)
	json_save_var_bool("exportimage_remove_background", popup_exportimage.remove_background)
	json_save_var_bool("exportimage_include_hidden", popup_exportimage.include_hidden)
	json_save_var_bool("exportimage_high_quality", popup_exportimage.high_quality)

json_save_object_done()

json_save_object_start("collapse")

	var key = ds_map_find_first(collapse_map);
	
	while (!is_undefined(key))
	{
		json_save_var_bool(key, collapse_map[?key])
		key = ds_map_find_next(collapse_map, key)
	}

json_save_object_done()

json_save_object_done()
json_save_done()

debug("Saved settings")