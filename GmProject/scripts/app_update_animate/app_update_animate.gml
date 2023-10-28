/// app_update_animate()
/// @desc Handles the playing of various animations. Runs once per step.

function app_update_animate()
{
	// Go through timelines
	var bgobject, updatevalues, cameraarr;
	updatevalues = (timeline_marker_previous != timeline_marker)
	bgobject = null
	cameraarr = array()
	background_light_amount = 1
	background_light_data[0] = 0
	background_sun_direction = vec3(0)
	
	project_path_tl_array = []
	project_use_path_tl_array = []
	project_ik_part_array = [] // If null, will generate in tl_update_matrix
	project_inherit_pose_array = []
	
	// Update background time
	background_time_prev = background_time
	background_time = (timeline_marker / project_tempo) * 60
	
	// Update samples
	if ((background_time_prev != background_time || app.history_resource_update) || app.timeline_playing)
		render_samples = -1
	
	with (obj_timeline)
	{
		// Update values
		if (updatevalues)
			tl_update_values()
		
		tex_obj = value_inherit[e_value.TEXTURE_OBJ]
		
		// Update render resource
		if ((tex_obj != tex_obj_prev) || app.history_resource_update)
		{
			if (render_visible)
			{
				if (render_update_tl_resource())
					tex_obj_prev = tex_obj
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
			particle_spawner_update(id)
		
		// Find background changer
		if (type = e_tl_type.BACKGROUND && value_inherit[e_value.VISIBLE] && !hide)
			bgobject = id
		
		// Add light
		if ((type = e_tl_type.POINT_LIGHT || type = e_tl_type.SPOT_LIGHT) && value_inherit[e_value.VISIBLE])
		{
			// Invisible via timeline?
			if ((hide && !render_hidden) || (!app.view_render && lq_hiding))
				continue
			
			app.background_light_data[app.background_light_amount * 8 + 0] = world_pos[X]
			app.background_light_data[app.background_light_amount * 8 + 1] = world_pos[Y]
			app.background_light_data[app.background_light_amount * 8 + 2] = world_pos[Z]
			app.background_light_data[app.background_light_amount * 8 + 3] = value[e_value.LIGHT_RANGE]
			app.background_light_data[app.background_light_amount * 8 + 4] = (color_get_red(value[e_value.LIGHT_COLOR]) / 255) * value[e_value.LIGHT_STRENGTH]
			app.background_light_data[app.background_light_amount * 8 + 5] = (color_get_green(value[e_value.LIGHT_COLOR]) / 255) * value[e_value.LIGHT_STRENGTH]
			app.background_light_data[app.background_light_amount * 8 + 6] = (color_get_blue(value[e_value.LIGHT_COLOR]) / 255) * value[e_value.LIGHT_STRENGTH]
			app.background_light_data[app.background_light_amount * 8 + 7] = 1
			app.background_light_amount++
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
	{
		with (app)
			tl_update_matrix(true)
	}
	
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
	timeline_marker_previous = timeline_marker
	
	// Background
	if (bgobject)
	{
		background_image_show					= bgobject.value[e_value.BG_IMAGE_SHOW]
		background_image_rotation				= bgobject.value[e_value.BG_IMAGE_ROTATION]
		background_sky_sun_angle				= bgobject.value[e_value.BG_SKY_SUN_ANGLE]
		background_sky_sun_scale				= bgobject.value[e_value.BG_SKY_SUN_SCALE]
		background_sky_moon_phase				= bgobject.value[e_value.BG_SKY_MOON_PHASE]
		background_sky_moon_angle				= bgobject.value[e_value.BG_SKY_MOON_ANGLE]
		background_sky_moon_scale				= bgobject.value[e_value.BG_SKY_MOON_SCALE]
		background_sky_time						= bgobject.value[e_value.BG_SKY_TIME]
		background_sky_rotation					= bgobject.value[e_value.BG_SKY_ROTATION]
		background_sunlight_strength			= bgobject.value[e_value.BG_SUNLIGHT_STRENGTH]
		background_sunlight_angle				= bgobject.value[e_value.BG_SUNLIGHT_ANGLE]
		background_twilight						= bgobject.value[e_value.BG_TWILIGHT]
		background_sky_clouds_show				= bgobject.value[e_value.BG_SKY_CLOUDS_SHOW]
		background_sky_clouds_speed				= bgobject.value[e_value.BG_SKY_CLOUDS_SPEED]
		background_sky_clouds_height			= bgobject.value[e_value.BG_SKY_CLOUDS_HEIGHT]
		background_sky_clouds_offset			= bgobject.value[e_value.BG_SKY_CLOUDS_OFFSET]
		background_ground_show					= bgobject.value[e_value.BG_GROUND_SHOW]
		background_ground_slot					= bgobject.value[e_value.BG_GROUND_SLOT]
		background_biome						= bgobject.value[e_value.BG_BIOME]
		background_sky_color					= bgobject.value[e_value.BG_SKY_COLOR]
		background_sky_clouds_color				= bgobject.value[e_value.BG_SKY_CLOUDS_COLOR]
		background_sunlight_color				= bgobject.value[e_value.BG_SUNLIGHT_COLOR]
		background_ambient_color				= bgobject.value[e_value.BG_AMBIENT_COLOR]
		background_night_color					= bgobject.value[e_value.BG_NIGHT_COLOR]
		background_grass_color					= bgobject.value[e_value.BG_GRASS_COLOR]
		background_foliage_color				= bgobject.value[e_value.BG_FOLIAGE_COLOR]
		background_water_color					= bgobject.value[e_value.BG_WATER_COLOR]
		background_leaves_oak_color				= bgobject.value[e_value.BG_LEAVES_OAK_COLOR]
		background_leaves_spruce_color			= bgobject.value[e_value.BG_LEAVES_SPRUCE_COLOR]
		background_leaves_birch_color			= bgobject.value[e_value.BG_LEAVES_BIRCH_COLOR]
		background_leaves_jungle_color			= bgobject.value[e_value.BG_LEAVES_JUNGLE_COLOR]
		background_leaves_acacia_color			= bgobject.value[e_value.BG_LEAVES_ACACIA_COLOR]
		background_leaves_dark_oak_color		= bgobject.value[e_value.BG_LEAVES_DARK_OAK_COLOR]
		background_leaves_mangrove_color		= bgobject.value[e_value.BG_LEAVES_MANGROVE_COLOR]
		background_fog_show						= bgobject.value[e_value.BG_FOG_SHOW]
		background_fog_sky						= bgobject.value[e_value.BG_FOG_SKY]
		background_fog_color_custom				= bgobject.value[e_value.BG_FOG_CUSTOM_COLOR]
		background_fog_color					= bgobject.value[e_value.BG_FOG_COLOR]
		background_fog_custom_object_color		= bgobject.value[e_value.BG_FOG_CUSTOM_OBJECT_COLOR]
		background_fog_object_color				= bgobject.value[e_value.BG_FOG_OBJECT_COLOR]
		background_fog_distance					= bgobject.value[e_value.BG_FOG_DISTANCE]
		background_fog_size						= bgobject.value[e_value.BG_FOG_SIZE]
		background_fog_height					= bgobject.value[e_value.BG_FOG_HEIGHT]
		background_wind							= bgobject.value[e_value.BG_WIND]
		background_wind_speed					= bgobject.value[e_value.BG_WIND_SPEED]
		background_wind_strength				= bgobject.value[e_value.BG_WIND_STRENGTH]
		background_wind_direction				= bgobject.value[e_value.BG_WIND_DIRECTION]
		background_wind_directional_speed		= bgobject.value[e_value.BG_WIND_DIRECTIONAL_SPEED]
		background_wind_directional_strength	= bgobject.value[e_value.BG_WIND_DIRECTIONAL_STRENGTH]
		background_texture_animation_speed		= bgobject.value[e_value.BG_TEXTURE_ANI_SPEED]
		
		if (background_biome = "custom" || background_biome_prev != background_biome)
		{
			with (obj_resource)
				res_update_colors()
			
			properties.library.preview.update = true
			background_biome_prev = background_biome
		}
		
		background_ground_update_texture()
		background_ground_update_texture_material()
		background_ground_update_texture_normal()
	}
	
	// Update sun direction
	background_sky_update_sun()
	
	// Colors
	background_night_alpha = background_sky_night_alpha()
	background_sunset_alpha = background_sky_rise_set_alpha(false)
	background_sunrise_alpha = background_sky_rise_set_alpha(true)
	
	var twilight_color = merge_color(background_sunlight_color, background_twilight ? c_red : c_white, max(background_sunrise_alpha, background_sunset_alpha) * 0.75);
	background_sunlight_color_final = merge_color(twilight_color, c_black, background_night_alpha)
	background_ambient_color_final = merge_color(background_ambient_color, background_night_color, background_night_alpha)
	background_fog_color_final = background_fog_color
	
	background_sky_color_final = merge_color(background_sky_color, hex_to_color("020204"), background_sky_night_alpha())
	
	// Cameras
	if (window_state = "export_movie")
		app_update_cameras(exportmovie_high_quality, true)
	else
		app_update_cameras(view_render, false)
	
	// Update current marker
	timeline_marker_current = null
	
	for (var i = 0; i < ds_list_size(timeline_marker_list); i++)
	{
		if (timeline_marker >= timeline_marker_list[|i].pos)
			timeline_marker_current = timeline_marker_list[|i]
	}
	
	history_resource_update = false
}
