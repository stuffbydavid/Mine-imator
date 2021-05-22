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

function settings_load()
{
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
			room_speed = value_get_real(programmap[?"fps"], room_speed)
			
			if (!dev_mode)
				setting_project_folder = value_get_string(programmap[?"project_folder"], setting_project_folder)
			if (!directory_exists_lib(setting_project_folder))
				setting_project_folder = projects_directory
			
			setting_backup = value_get_real(programmap[?"backup"], setting_backup)
			setting_backup_time = value_get_real(programmap[?"backup_time"], setting_backup_time)
			setting_backup_amount = value_get_real(programmap[?"backup_amount"], setting_backup_amount)
			setting_spawn_objects = value_get_real(programmap[?"spawn_objects"], setting_spawn_objects)
			setting_spawn_cameras = value_get_real(programmap[?"spawn_cameras"], setting_spawn_cameras)
			setting_unlimited_values = value_get_real(programmap[?"unlimited_values"], setting_unlimited_values)
		}
		
		// Interface
		var interfacemap = map[?"interface"];
		if (ds_map_valid(interfacemap))
		{
			setting_view_real_time_render = value_get_real(interfacemap[?"view_real_time_render"], setting_view_real_time_render)
			setting_view_real_time_render_time = value_get_real(interfacemap[?"view_real_time_render_time"], setting_view_real_time_render_time)
			
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
			update_interface_wait = true
			
			setting_timeline_autoscroll = value_get_real(interfacemap[?"timeline_autoscroll"], setting_timeline_autoscroll)
			setting_timeline_compact = value_get_real(interfacemap[?"timeline_compact"], setting_timeline_compact)
			setting_timeline_select_jump = value_get_real(interfacemap[?"timeline_select_jump"], setting_timeline_select_jump)
			setting_timeline_hide_ghosts = value_get_real(interfacemap[?"timeline_hide_ghosts"], setting_timeline_hide_ghosts)
			setting_z_is_up = value_get_real(interfacemap[?"z_is_up"], setting_z_is_up)
			setting_smooth_camera = value_get_real(interfacemap[?"smooth_camera"], setting_smooth_camera)
			setting_search_variants = value_get_real(interfacemap[?"search_variants"], setting_search_variants)
			setting_show_shortcuts_bar = value_get_real(interfacemap[?"show_shortcuts_bar"], setting_show_shortcuts_bar)
			
			setting_toolbar_location = value_get_string(interfacemap[?"toolbar_location"], setting_toolbar_location)
			setting_toolbar_size = value_get_real(interfacemap[?"toolbar_size"], setting_toolbar_size)
			
			setting_panel_left_bottom_size = value_get_real(interfacemap[?"panel_left_bottom_size"], setting_panel_left_bottom_size)
			setting_panel_right_bottom_size = value_get_real(interfacemap[?"panel_right_bottom_size"], setting_panel_right_bottom_size)
			setting_panel_bottom_size = value_get_real(interfacemap[?"panel_bottom_size"], setting_panel_bottom_size)
			setting_panel_top_size = value_get_real(interfacemap[?"panel_top_size"], setting_panel_top_size)
			setting_panel_left_top_size = value_get_real(interfacemap[?"panel_left_top_size"], setting_panel_left_top_size)
			setting_panel_right_top_size = value_get_real(interfacemap[?"panel_right_top_size"], setting_panel_right_top_size)
			
			setting_properties_location = value_get_string(interfacemap[?"properties_location"], setting_properties_location)
			setting_ground_editor_location = value_get_string(interfacemap[?"ground_editor_location"], setting_ground_editor_location)
			setting_template_editor_location = value_get_string(interfacemap[?"template_editor_location"], setting_template_editor_location)
			setting_timeline_location = value_get_string(interfacemap[?"timeline_location"], setting_timeline_location)
			setting_timeline_editor_location = value_get_string(interfacemap[?"timeline_editor_location"], setting_timeline_editor_location)
			setting_frame_editor_location = value_get_string(interfacemap[?"frame_editor_location"], setting_frame_editor_location)
			setting_frame_editor_color_advanced = value_get_real(interfacemap[?"frame_editor_color_advanced"], setting_frame_editor_color_advanced)
			setting_settings_location = value_get_string(interfacemap[?"settings_location"], setting_settings_location)
			
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
				obj = keybinds_map[?i]
				obj.keybind = value_get_array(controlsmap[?obj.name], obj.keybind)
			}
			
			setting_move_speed = value_get_real(controlsmap[?"move_speed"], setting_move_speed)
			setting_look_sensitivity = value_get_real(controlsmap[?"look_sensitivity"], setting_look_sensitivity)
			setting_fast_modifier = value_get_real(controlsmap[?"fast_modifier"], setting_fast_modifier)
			setting_slow_modifier = value_get_real(controlsmap[?"slow_modifier"], setting_slow_modifier)
		}
		
		// Graphics
		var graphicsmap = map[?"graphics"];
		if (ds_map_valid(graphicsmap))
		{
			if (load_format < e_settings.FORMAT_120)
				setting_bend_style = (value_get_real(graphicsmap[?"bend_pinch"], true) ? "realistic" : "blocky")
			else
				setting_bend_style = value_get_string(graphicsmap[?"bend_style"], setting_bend_style)
			
			if (load_format < e_settings.FORMAT_130)
				setting_scenery_remove_edges = value_get_real(graphicsmap[?"schematic_remove_edges"], setting_scenery_remove_edges)
			else
				setting_scenery_remove_edges = value_get_real(graphicsmap[?"scenery_remove_edges"], setting_scenery_remove_edges)
			
			setting_liquid_animation = value_get_real(graphicsmap[?"liquid_animation"], setting_liquid_animation)
			setting_noisy_grass_water = value_get_real(graphicsmap[?"noisy_grass_water"], setting_noisy_grass_water)
			setting_remove_waterlogged_water = value_get_real(graphicsmap[?"remove_waterlogged_water"], setting_remove_waterlogged_water)
			setting_texture_filtering = value_get_real(graphicsmap[?"texture_filtering"], setting_texture_filtering)
			setting_transparent_block_texture_filtering = value_get_real(graphicsmap[?"transparent_block_texture_filtering"], setting_transparent_block_texture_filtering)
			setting_texture_filtering_level = value_get_real(graphicsmap[?"texture_filtering_level"], setting_texture_filtering_level)
			setting_block_brightness = value_get_real(graphicsmap[?"block_brightness"], setting_block_brightness)
			setting_block_glow_threshold = value_get_real(graphicsmap[?"block_glow_threshold"], setting_block_glow_threshold)
			setting_block_glow = value_get_real(graphicsmap[?"block_glow"], setting_block_glow)
			
			if (load_format < e_settings.FORMAT_130)
			{
				var lightbleed = value_get_real(graphicsmap[?"light_bleeding"], true);
				
				// Multiply by default value
				setting_block_subsurface = lightbleed * 2
			}
			else
				setting_block_subsurface = value_get_real(graphicsmap[?"block_subsurface"], setting_block_subsurface)
		}
		
		// Render
		var rendermap = map[?"render"];
		if (ds_map_valid(rendermap))
		{
			setting_render_samples = value_get_real(rendermap[?"render_samples"], setting_render_samples)
			setting_render_dof_quality = value_get_real(rendermap[?"render_dof_quality"], setting_render_dof_quality)
			
			setting_render_ssao = value_get_real(rendermap[?"render_ssao"], setting_render_ssao)
			setting_render_ssao_radius = value_get_real(rendermap[?"render_ssao_radius"], setting_render_ssao_radius)
			setting_render_ssao_power = value_get_real(rendermap[?"render_ssao_power"], setting_render_ssao_power)
			setting_render_ssao_blur_passes = value_get_real(rendermap[?"render_ssao_blur_passes"], setting_render_ssao_blur_passes)
			setting_render_ssao_color = value_get_color(rendermap[?"render_ssao_color"], setting_render_ssao_color)
			
			setting_render_shadows = value_get_real(rendermap[?"render_shadows"], setting_render_shadows)
			setting_render_shadows_sun_buffer_size = value_get_real(rendermap[?"render_shadows_sun_buffer_size"], setting_render_shadows_sun_buffer_size)
			setting_render_shadows_spot_buffer_size = value_get_real(rendermap[?"render_shadows_spot_buffer_size"], setting_render_shadows_spot_buffer_size)
			setting_render_shadows_point_buffer_size = value_get_real(rendermap[?"render_shadows_point_buffer_size"], setting_render_shadows_point_buffer_size)
			setting_render_shadows_sun_colored = value_get_real(rendermap[?"render_shadows_sun_colored"], setting_render_shadows_sun_colored)
			
			setting_render_subsurface_samples = value_get_real(rendermap[?"render_subsurface_samples"], setting_render_subsurface_samples)
			setting_render_subsurface_jitter = value_get_real(rendermap[?"render_subsurface_jitter"], setting_render_subsurface_jitter)
			
			setting_render_indirect = value_get_real(rendermap[?"render_indirect"], setting_render_indirect)
			setting_render_indirect_blur_passes = value_get_real(rendermap[?"render_indirect_blur_passes"], setting_render_indirect_blur_passes)
			setting_render_indirect_quality = value_get_real(rendermap[?"render_indirect_quality"], setting_render_indirect_quality)
			setting_render_indirect_strength = value_get_real(rendermap[?"render_indirect_strength"], setting_render_indirect_strength)
			setting_render_indirect_range = value_get_real(rendermap[?"render_indirect_range"], setting_render_indirect_range)
			
			setting_render_reflections = value_get_real(rendermap[?"render_reflections"], setting_render_reflections)
			setting_render_reflections_precision = value_get_real(rendermap[?"render_reflections_precision"], setting_render_reflections_precision)
			setting_render_reflections_thickness = value_get_real(rendermap[?"render_reflections_thickness"], setting_render_reflections_thickness)
			setting_render_reflections_fade_amount = value_get_real(rendermap[?"render_reflections_fade_amount"], setting_render_reflections_fade_amount)
			setting_render_reflections_halfres = value_get_real(rendermap[?"render_reflections_halfres"], setting_render_reflections_halfres)
			
			setting_render_glow = value_get_real(rendermap[?"render_glow"], setting_render_glow)
			setting_render_glow_radius = value_get_real(rendermap[?"render_glow_radius"], setting_render_glow_radius)
			setting_render_glow_intensity = value_get_real(rendermap[?"render_glow_intensity"], setting_render_glow_intensity)
			setting_render_glow_falloff = value_get_real(rendermap[?"render_glow_falloff"], setting_render_glow_falloff)
			setting_render_glow_falloff_radius = value_get_real(rendermap[?"render_glow_falloff_radius"], setting_render_glow_falloff_radius)
			setting_render_glow_falloff_intensity = value_get_real(rendermap[?"render_glow_falloff_intensity"], setting_render_glow_falloff_intensity)
			
			setting_render_aa = value_get_real(rendermap[?"render_aa"], setting_render_aa)
			setting_render_aa_power = value_get_real(rendermap[?"render_aa_power"], setting_render_aa_power)
			
			setting_render_watermark_filename = value_get_string(rendermap[?"render_watermark_filename"], setting_render_watermark_filename)
			
			if (!file_exists_lib(setting_render_watermark_filename))
				setting_render_watermark_filename = ""
			else if (setting_render_watermark_filename != "")
				action_setting_render_watermark_open(setting_render_watermark_filename)
			
			setting_render_watermark_anchor_x = value_get_string(rendermap[?"render_watermark_anchor_x"], setting_render_watermark_anchor_x)
			setting_render_watermark_anchor_y = value_get_string(rendermap[?"render_watermark_anchor_y"], setting_render_watermark_anchor_y)
			setting_render_watermark_scale = value_get_real(rendermap[?"render_watermark_scale"], setting_render_watermark_scale)
			setting_render_watermark_alpha = value_get_real(rendermap[?"render_watermark_alpha"], setting_render_watermark_alpha)
			
			setting_export_movie_format = value_get_string(rendermap[?"export_movie_format"], setting_export_movie_format)
			setting_export_movie_frame_rate = value_get_string(rendermap[?"export_movie_frame_rate"], setting_export_movie_frame_rate)
			setting_export_movie_bit_rate = value_get_string(rendermap[?"export_movie_bit_rate"], setting_export_movie_bit_rate)
			setting_export_movie_include_audio = value_get_string(rendermap[?"export_movie_include_audio"], setting_export_movie_include_audio)
			setting_export_movie_remove_background = value_get_string(rendermap[?"export_movie_remove_background"], setting_export_movie_remove_background)
			setting_export_movie_include_hidden = value_get_string(rendermap[?"export_movie_remove_background"], setting_export_movie_include_hidden)
			setting_export_movie_high_quality = value_get_string(rendermap[?"export_movie_high_quality"], setting_export_movie_high_quality)
			setting_export_movie_watermark = value_get_string(rendermap[?"export_movie_watermark"], setting_export_movie_watermark)
			setting_export_image_remove_background = value_get_string(rendermap[?"export_image_remove_background"], setting_export_image_remove_background)
			setting_export_image_include_hidden = value_get_string(rendermap[?"export_image_include_hidden"], setting_export_image_include_hidden)
			setting_export_image_high_quality = value_get_string(rendermap[?"export_image_high_quality"], setting_export_image_high_quality)
			setting_export_image_watermark = value_get_string(rendermap[?"export_image_watermark"], setting_export_image_watermark)
		}
		
		// Collapsible content
		var collapsemap = map[?"collapse"];
		if (ds_map_valid(collapsemap))
		{
			var key = ds_map_find_first(collapse_map);
			
			while (!is_undefined(key))
			{
				collapse_map[?key] = value_get_string(collapsemap[?key], collapse_map[?key])
				key = ds_map_find_next(collapse_map, key)
			}
		}
	}
	
	// Legacy
	else
	{
		settings_load_legacy(fn)
		settings_load_legacy_recent(data_directory + "recent.file")
	}
}
