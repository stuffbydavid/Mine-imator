/// @desc Handles the playing of various animations. Runs once per step.

function app_update_animate()
{
	// Go through timelines
	var envobject, updatevalues, cameraarr, spawnerarr, starttime, biomeani;
	updatevalues = (timeline_marker_previous != timeline_marker)
	biomeani = (env_biome_next != env_biome)
	envobject = null
	cameraarr = []
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
	if ((env_time_prev != env_time || app.history_resource_update) || app.timeline_playing)
		render_samples = -1
	
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
		
		// Get cameras
		if (type = e_tl_type.CAMERA)
		{
			array_add(cameraarr, id)
			
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
		
		// Find environment changer
		if (type = e_tl_type.ENVIRONMENT && value_inherit[e_value.VISIBLE] && !hide)
			envobject = id
		
		// Add light
		if ((type = e_tl_type.POINT_LIGHT || type = e_tl_type.SPOT_LIGHT) && value_inherit[e_value.VISIBLE])
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
	
	// Find camera
	timeline_camera = null
	for (var i = 0; i < array_length(cameraarr); i++)
	{
		var cam = cameraarr[i];
		if (cam.selected || (cam.value_inherit[e_value.VISIBLE] && !cam.hide))
		{
			timeline_camera = cam
			break
		}
	}
	
	// Invalidate camera effects
	timeline_camera_effect_value = null
	timeline_camera_effect_enabled = null
	
	timeline_marker_previous = timeline_marker
	
	// Environment
	timeline_environment = null
	env_biome_next = env_biome
	env_biome_mix = 0
	
	if (envobject)
	{
		timeline_environment = envobject
		
		env_background_image_show		= envobject.value[e_value.ENV_IMAGE_SHOW]
		env_background_image_rotation	= envobject.value[e_value.ENV_IMAGE_ROTATION]
		env_sky_sun_angle				= envobject.value[e_value.ENV_SKY_SUN_ANGLE]
		env_sky_sun_scale				= envobject.value[e_value.ENV_SKY_SUN_SCALE]
		env_sky_moon_phase				= envobject.value[e_value.ENV_SKY_MOON_PHASE]
		env_sky_moon_angle				= envobject.value[e_value.ENV_SKY_MOON_ANGLE]
		env_sky_moon_scale				= envobject.value[e_value.ENV_SKY_MOON_SCALE]
		env_sky_time					= envobject.value[e_value.ENV_SKY_TIME]
		env_sky_rotation				= envobject.value[e_value.ENV_SKY_ROTATION]
		env_sunlight_strength			= envobject.value[e_value.ENV_SUNLIGHT_STRENGTH]
		env_sunlight_specular_strength	= envobject.value[e_value.ENV_SUNLIGHT_SPECULAR_STRENGTH]
		env_sunlight_angle				= envobject.value[e_value.ENV_SUNLIGHT_ANGLE]
		env_twilight					= envobject.value[e_value.ENV_TWILIGHT]
		env_sky_clouds_show				= envobject.value[e_value.ENV_SKY_CLOUDS_SHOW]
		env_sky_clouds_speed			= envobject.value[e_value.ENV_SKY_CLOUDS_SPEED]
		env_sky_clouds_offset_y			= envobject.value[e_value.ENV_SKY_CLOUDS_OFFSET_Y]
		env_sky_clouds_offset_z			= envobject.value[e_value.ENV_SKY_CLOUDS_OFFSET_Z]
		env_ground_show					= envobject.value[e_value.ENV_GROUND_SHOW]
		env_ground_slot					= envobject.value[e_value.ENV_GROUND_SLOT]
		env_biome						= envobject.value[e_value.ENV_BIOME]
		env_sky_color					= envobject.value[e_value.ENV_SKY_COLOR]
		env_sky_clouds_color			= envobject.value[e_value.ENV_SKY_CLOUDS_COLOR]
		env_sunlight_color				= envobject.value[e_value.ENV_SUNLIGHT_COLOR]
		env_ambient_color				= envobject.value[e_value.ENV_AMBIENT_COLOR]
		env_night_sky_color				= envobject.value[e_value.ENV_NIGHT_SKY_COLOR]
		env_night_sky_clouds_color		= envobject.value[e_value.ENV_NIGHT_SKY_CLOUDS_COLOR]
		env_night_sky_stars_color		= envobject.value[e_value.ENV_NIGHT_SKY_STARS_COLOR]
		env_night_color					= envobject.value[e_value.ENV_NIGHT_COLOR]
		env_grass_color					= envobject.value[e_value.ENV_GRASS_COLOR]
		env_foliage_color				= envobject.value[e_value.ENV_FOLIAGE_COLOR]
		env_dry_foliage_color			= envobject.value[e_value.ENV_DRY_FOLIAGE_COLOR]
		env_water_color					= envobject.value[e_value.ENV_WATER_COLOR]
		env_leaves_oak_color			= envobject.value[e_value.ENV_LEAVES_OAK_COLOR]
		env_leaves_spruce_color			= envobject.value[e_value.ENV_LEAVES_SPRUCE_COLOR]
		env_leaves_birch_color			= envobject.value[e_value.ENV_LEAVES_BIRCH_COLOR]
		env_leaves_jungle_color			= envobject.value[e_value.ENV_LEAVES_JUNGLE_COLOR]
		env_leaves_acacia_color			= envobject.value[e_value.ENV_LEAVES_ACACIA_COLOR]
		env_leaves_dark_oak_color		= envobject.value[e_value.ENV_LEAVES_DARK_OAK_COLOR]
		env_leaves_mangrove_color		= envobject.value[e_value.ENV_LEAVES_MANGROVE_COLOR]
		env_fog_show					= envobject.value[e_value.ENV_FOG_SHOW]
		env_fog_sky						= envobject.value[e_value.ENV_FOG_SKY]
		env_fog_color_custom			= envobject.value[e_value.ENV_FOG_CUSTOM_COLOR]
		env_fog_color					= envobject.value[e_value.ENV_FOG_COLOR]
		env_fog_custom_object_color		= envobject.value[e_value.ENV_FOG_CUSTOM_OBJECT_COLOR]
		env_fog_object_color			= envobject.value[e_value.ENV_FOG_OBJECT_COLOR]
		env_fog_distance				= envobject.value[e_value.ENV_FOG_DISTANCE]
		env_fog_size					= envobject.value[e_value.ENV_FOG_SIZE]
		env_fog_height					= envobject.value[e_value.ENV_FOG_HEIGHT]
		env_wind						= envobject.value[e_value.ENV_WIND]
		env_wind_speed					= envobject.value[e_value.ENV_WIND_SPEED]
		env_wind_strength				= envobject.value[e_value.ENV_WIND_STRENGTH]
		env_wind_direction				= envobject.value[e_value.ENV_WIND_DIRECTION]
		env_wind_directional_speed		= envobject.value[e_value.ENV_WIND_DIRECTIONAL_SPEED]
		env_wind_directional_strength	= envobject.value[e_value.ENV_WIND_DIRECTIONAL_STRENGTH]
		env_texture_animation_speed		= envobject.value[e_value.ENV_TEXTURE_ANI_SPEED]
		env_brightness					= envobject.value[e_value.ENV_BRIGHTNESS]
		
		env_biome_next = env_biome
		
		if (envobject.keyframe_animate && env_biome != envobject.keyframe_next_values[e_value.ENV_BIOME])
		{
			env_biome_next = envobject.keyframe_next_values[e_value.ENV_BIOME]
			env_biome_mix = clamp(envobject.keyframe_progress_ease, 0, 1)
			
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
