/// @desc Handles the playing of various animations. Runs once per step.

function app_update_animate()
{
	if (timeline_move_obj != null)
		return 0
	
	// Go through timelines
	var envobj, updatevalues, spawnerarr, starttime, biomeani;
	updatevalues = (timeline_marker_previous != timeline_marker)
	biomeani = (env_biome_next != env_biome)
	spawnerarr = []
	starttime = get_timer()
	
	env_light_amount = 1
	env_light_data[0] = 0
	env_sun_direction = vec3(0)
	
	project_path_tl_array = []
	project_use_path_tl_array = []
	project_ik_part_array = [] // If null, will generate in tl_update_matrix
	project_inherit_pose_array = []
	
	// Update background time
	env_time_prev = env_time
	env_time = (timeline_marker / project_tempo) * 60
	
	// Update samples
	if (updatevalues || env_time_prev != env_time || app.history_resource_update || app.timeline_playing)
	{
		render_samples = -1
		view_changed()
	}
	
	with (obj_timeline)
	{
		// Update values
		if (updatevalues)
			tl_update_values()
		
		tex_obj = value_inherit[e_value.TEXTURE_OBJ]
		tex_obj_material = value_inherit[e_value.TEXTURE_MATERIAL_OBJ]
		tex_obj_normal = value_inherit[e_value.TEXTURE_NORMAL_OBJ]
		
		// Update render resource
		if (tex_obj != tex_obj_prev ||
			tex_obj_material != tex_obj_material_prev ||
			tex_obj_normal != tex_obj_normal_prev ||
			app.history_resource_update)
		{
			if (render_visible)
			{
				if (render_update_tl_resource())
				{
					tex_obj_prev = tex_obj
					tex_obj_material_prev = tex_obj_material
					tex_obj_normal_prev = tex_obj_normal
				}
			}
		}
		
		// Get path timelines
		if (type = e_tl_type.PATH)
			array_add(app.project_path_tl_array, id)
		
		// Get timelines that use paths
		if (value[e_value.PATH_OBJ] != null)
			array_add(app.project_use_path_tl_array, id)
		
		// Get timelines that use IK (Uses "End offset", bend on "Lower", and only on "X" axis)
		if (tl_supports_ik())
			array_add(app.project_ik_part_array, id)
		
		// Update camera zoom
		if (type = e_tl_type.CAMERA)
		{
			// Animated zoom
			if (app.window_busy = "") 
			{
				if (cam_goalzoom > 0 && abs(cam_goalzoom - value[e_value.CAM_ROTATE_DISTANCE]) > 0.001)
				{
					with (app)
					{
						tl_value_set_start(action_tl_frame_cam_rotate_distance, true)
						tl_value_set(e_value.CAM_ROTATE_DISTANCE, (other.cam_goalzoom - other.value[e_value.CAM_ROTATE_DISTANCE]) / max(1, 4 / delta), true)
						tl_value_set_done()
					}
				}
				else
					cam_goalzoom = null
			}
		}
		
		// Update spawner
		if (type = e_temp_type.PARTICLE_SPAWNER)
			array_add(spawnerarr, id)
		
		// Add light
		if (type_is_light(type) && value_inherit[e_value.VISIBLE])
		{
			// Invisible via timeline?
			if ((hide && !render_hidden) || !mode_visible[renderer_current])
				continue
			
			app.env_light_data[app.env_light_amount * 8 + 0] = world_pos[X]
			app.env_light_data[app.env_light_amount * 8 + 1] = world_pos[Y]
			app.env_light_data[app.env_light_amount * 8 + 2] = world_pos[Z]
			app.env_light_data[app.env_light_amount * 8 + 3] = value[e_value.LIGHT_RANGE]
			app.env_light_data[app.env_light_amount * 8 + 4] = (color_get_red(value[e_value.LIGHT_COLOR]) / 255) * value[e_value.LIGHT_STRENGTH]
			app.env_light_data[app.env_light_amount * 8 + 5] = (color_get_green(value[e_value.LIGHT_COLOR]) / 255) * value[e_value.LIGHT_STRENGTH]
			app.env_light_data[app.env_light_amount * 8 + 6] = (color_get_blue(value[e_value.LIGHT_COLOR]) / 255) * value[e_value.LIGHT_STRENGTH]
			app.env_light_data[app.env_light_amount * 8 + 7] = 1
			app.env_light_amount++
		}
		
		// Block rendering
		tl_update_block_render()
	}
	
	if (updatevalues)
		tl_update_matrix()
	
	// Update paths
	for (var i = 0; i < array_length(project_path_tl_array); i++)
	{
		with (project_path_tl_array[i])
		{
			if (path_update)
			{
				tl_update_path()
				path_update = false
			}
		}
	}
	
	// Update timelines with path transform
	for (var i = 0; i < array_length(project_use_path_tl_array); i++)
		project_use_path_tl_array[i].update_matrix = true
	
	if (array_length(project_use_path_tl_array) > 0)
		with (app)
			tl_update_matrix(true)

	render_alpha_hashing_update()
	
	// Spawn particles
	for (var i = 0; i < array_length(spawnerarr); i++)
		with (spawnerarr[i])
			particle_spawner_update(spawnerarr[i])
	
	// Clear cached IK tl IDs (In case of removal, etc. tl_update_matrix will re-generate)
	project_ik_part_array = null
	
	// Find the first active camera and environment in timeline order
	timeline_camera = null
	timeline_environment = null
	
	for (var i = 0; i < ds_list_size(project_timeline_list); i++)
	{
		var tl = project_timeline_list[|i];
		if (timeline_camera = null && tl.type = e_tl_type.CAMERA &&
			(tl.selected || (tl.value_inherit[e_value.VISIBLE] && !tl.hide)))
			timeline_camera = tl

		if (timeline_environment = null && tl.type = e_tl_type.ENVIRONMENT && tl.value_inherit[e_value.VISIBLE] && !tl.hide)
			timeline_environment = tl

		if (timeline_camera != null && timeline_environment != null)
			break
	}
	
	// Invalidate camera effects
	tl_camera_effects_reset()
	
	timeline_marker_previous = timeline_marker
	
	// Environment
	env_biome_next = env_biome
	env_biome_mix = 0
	
	if (timeline_environment)
	{
		var envobj = timeline_environment;
		env_background_image_show		= envobj.value[e_value.ENV_IMAGE_SHOW]
		env_background_image_rotation	= envobj.value[e_value.ENV_IMAGE_ROTATION]
		env_sky_sun_angle				= envobj.value[e_value.ENV_SKY_SUN_ANGLE]
		env_sky_sun_scale				= envobj.value[e_value.ENV_SKY_SUN_SCALE]
		env_sky_moon_phase				= envobj.value[e_value.ENV_SKY_MOON_PHASE]
		env_sky_moon_angle				= envobj.value[e_value.ENV_SKY_MOON_ANGLE]
		env_sky_moon_scale				= envobj.value[e_value.ENV_SKY_MOON_SCALE]
		env_sky_time					= envobj.value[e_value.ENV_SKY_TIME]
		env_sky_rotation				= envobj.value[e_value.ENV_SKY_ROTATION]
		env_sunlight_strength			= envobj.value[e_value.ENV_SUNLIGHT_STRENGTH]
		env_sunlight_specular_strength	= envobj.value[e_value.ENV_SUNLIGHT_SPECULAR_STRENGTH]
		env_sunlight_angle				= envobj.value[e_value.ENV_SUNLIGHT_ANGLE]
		env_twilight					= envobj.value[e_value.ENV_TWILIGHT]
		env_sky_clouds_show				= envobj.value[e_value.ENV_SKY_CLOUDS_SHOW]
		env_sky_clouds_speed			= envobj.value[e_value.ENV_SKY_CLOUDS_SPEED]
		env_sky_clouds_offset_y			= envobj.value[e_value.ENV_SKY_CLOUDS_OFFSET_Y]
		env_sky_clouds_offset_z			= envobj.value[e_value.ENV_SKY_CLOUDS_OFFSET_Z]
		env_ground_show					= envobj.value[e_value.ENV_GROUND_SHOW]
		env_ground_slot					= envobj.value[e_value.ENV_GROUND_SLOT]
		env_biome						= envobj.value[e_value.ENV_BIOME]
		env_sky_color					= envobj.value[e_value.ENV_SKY_COLOR]
		env_sky_clouds_color			= envobj.value[e_value.ENV_SKY_CLOUDS_COLOR]
		env_sunlight_color				= envobj.value[e_value.ENV_SUNLIGHT_COLOR]
		env_ambient_color				= envobj.value[e_value.ENV_AMBIENT_COLOR]
		env_night_sky_color				= envobj.value[e_value.ENV_NIGHT_SKY_COLOR]
		env_night_sky_clouds_color		= envobj.value[e_value.ENV_NIGHT_SKY_CLOUDS_COLOR]
		env_night_sky_stars_color		= envobj.value[e_value.ENV_NIGHT_SKY_STARS_COLOR]
		env_night_color					= envobj.value[e_value.ENV_NIGHT_COLOR]
		for (var i = 0; i < e_biome_color.amount; i++)
			env_color_list[i] = envobj.value[e_value.ENV_GRASS_COLOR + i]
		env_fog_show					= envobj.value[e_value.ENV_FOG_SHOW]
		env_fog_sky						= envobj.value[e_value.ENV_FOG_SKY]
		env_fog_color_custom			= envobj.value[e_value.ENV_FOG_CUSTOM_COLOR]
		env_fog_color					= envobj.value[e_value.ENV_FOG_COLOR]
		env_fog_custom_object_color		= envobj.value[e_value.ENV_FOG_CUSTOM_OBJECT_COLOR]
		env_fog_object_color			= envobj.value[e_value.ENV_FOG_OBJECT_COLOR]
		env_fog_distance				= envobj.value[e_value.ENV_FOG_DISTANCE]
		env_fog_size					= envobj.value[e_value.ENV_FOG_SIZE]
		env_fog_height					= envobj.value[e_value.ENV_FOG_HEIGHT]
		env_wind						= envobj.value[e_value.ENV_WIND]
		env_wind_speed					= envobj.value[e_value.ENV_WIND_SPEED]
		env_wind_strength				= envobj.value[e_value.ENV_WIND_STRENGTH]
		env_wind_direction				= envobj.value[e_value.ENV_WIND_DIRECTION]
		env_wind_directional_speed		= envobj.value[e_value.ENV_WIND_DIRECTIONAL_SPEED]
		env_wind_directional_strength	= envobj.value[e_value.ENV_WIND_DIRECTIONAL_STRENGTH]
		env_texture_animation_speed		= envobj.value[e_value.ENV_TEXTURE_ANI_SPEED]
		env_brightness					= envobj.value[e_value.ENV_BRIGHTNESS]
		
		env_biome_next = env_biome
		
		if (envobj.keyframe_animate && env_biome != envobj.keyframe_next_values[e_value.ENV_BIOME])
		{
			env_biome_next = envobj.keyframe_next_values[e_value.ENV_BIOME]
			env_biome_mix = clamp(envobj.keyframe_progress_ease, 0, 1)
			
			with (obj_resource)
				res_update_colors(app.env_biome, app.env_biome_next, app.env_biome_mix)
			
			properties.library.preview.update = true
			env_biome_prev = env_biome
		}
		
		else if (env_biome = "custom" || env_biome_prev != env_biome || biomeani)
		{
			with (obj_resource)
				res_update_colors()
			
			properties.library.preview.update = true
			env_biome_prev = env_biome
		}
		
		env_ground_update_texture()
		env_ground_update_texture_material()
		env_ground_update_texture_normal()
	}
	else if (biomeani)
	{
		with (obj_resource)
			res_update_colors()
		properties.library.preview.update = true
		env_biome_prev = env_biome
	}
	
	// Update sun direction
	env_sky_update_sun()
	
	// Colors
	env_night_alpha = env_sky_night_alpha()
	env_sunset_alpha = env_sky_rise_set_alpha(false)
	env_sunrise_alpha = env_sky_rise_set_alpha(true)
	
	var twilightcolor = merge_color(env_sunlight_color, env_twilight ? c_red : c_white, max(env_sunrise_alpha, env_sunset_alpha) * 0.75);
	env_sunlight_color_final = merge_color(twilightcolor, c_black, env_night_alpha)
	env_ambient_color_final = merge_color(env_ambient_color, env_night_color, env_night_alpha)
	env_fog_color_final = env_fog_color
	
	env_sky_color_final = merge_color(env_sky_color, env_night_sky_color, env_sky_night_alpha())
	
	// Benchmark
	if (benchmark_mode)
		benchmark_animate_total_time += get_timer() - starttime
	
	// Cameras
	if (window_state = "export_movie")
		app_update_cameras(exportmovie_renderer, true)
			
	// Update current marker
	timeline_marker_current = null
	
	starttime = get_timer()
	for (var i = 0; i < ds_list_size(timeline_marker_list); i++)
	{
		if (timeline_marker >= timeline_marker_list[|i].pos)
			timeline_marker_current = timeline_marker_list[|i]
	}
	
	// Benchmark
	if (benchmark_mode)
		benchmark_animate_total_time += get_timer() - starttime
	
	history_resource_update = false
}
