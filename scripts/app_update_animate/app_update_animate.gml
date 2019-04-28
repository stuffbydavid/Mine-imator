/// app_update_animate()
/// @desc Handles the playing of various animations. Runs once per step.

// Go through timelines
var bgobject, updatevalues, cameraarr;
updatevalues = (timeline_marker_previous != timeline_marker)
bgobject = null
cameraarr = array()
background_light_amount = 1
background_light_data[0] = 0

with (obj_timeline)
{
	// Update values
	if (updatevalues)
		tl_update_values()
	
	// Update render resource
	if (tl_get_visible())
		render_update_tl_resource()
	
	if (type = e_tl_type.CAMERA)
	{
		array_add(cameraarr, id)
		
		// Animated zoom
		if (app.window_busy = "") 
		{
			if (cam_goalzoom > 0 && cam_goalzoom != value[e_value.CAM_ROTATE_DISTANCE])
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
		particle_spawner_update()
		
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
		app.background_light_data[app.background_light_amount * 8 + 4] = color_get_red(value[e_value.LIGHT_COLOR]) / 255
		app.background_light_data[app.background_light_amount * 8 + 5] = color_get_green(value[e_value.LIGHT_COLOR]) / 255
		app.background_light_data[app.background_light_amount * 8 + 6] = color_get_blue(value[e_value.LIGHT_COLOR]) / 255
		app.background_light_data[app.background_light_amount * 8 + 7] = 1
		app.background_light_amount++
	}
}

if (updatevalues)
	tl_update_matrix()

// Find camera
timeline_camera = null
for (var i = 0; i < array_length_1d(cameraarr); i++)
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
	background_sky_moon_phase				= bgobject.value[e_value.BG_SKY_MOON_PHASE]
	background_sky_time						= bgobject.value[e_value.BG_SKY_TIME]
	background_sky_rotation					= bgobject.value[e_value.BG_SKY_ROTATION]
	background_sunlight_range				= bgobject.value[e_value.BG_SUNLIGHT_RANGE]
	background_sunlight_follow				= bgobject.value[e_value.BG_SUNLIGHT_FOLLOW]
	background_sunlight_strength			= bgobject.value[e_value.BG_SUNLIGHT_STRENGTH]
	background_desaturate_night				= bgobject.value[e_value.BG_DESATURATE_NIGHT]
	background_desaturate_night_amount		= bgobject.value[e_value.BG_DESATURATE_NIGHT_AMOUNT]
	background_sky_clouds_show				= bgobject.value[e_value.BG_SKY_CLOUDS_SHOW]
	background_sky_clouds_speed				= bgobject.value[e_value.BG_SKY_CLOUDS_SPEED]
	background_sky_clouds_z					= bgobject.value[e_value.BG_SKY_CLOUDS_Z]
	background_sky_clouds_offset			= bgobject.value[e_value.BG_SKY_CLOUDS_OFFSET]
	background_ground_show					= bgobject.value[e_value.BG_GROUND_SHOW]
	background_sky_color					= bgobject.value[e_value.BG_SKY_COLOR]
	background_sky_clouds_color				= bgobject.value[e_value.BG_SKY_CLOUDS_COLOR]
	background_sunlight_color				= bgobject.value[e_value.BG_SUNLIGHT_COLOR]
	background_ambient_color				= bgobject.value[e_value.BG_AMBIENT_COLOR]
	background_night_color					= bgobject.value[e_value.BG_NIGHT_COLOR]
	background_grass_color					= bgobject.value[e_value.BG_GRASS_COLOR]
	background_foliage_color				= bgobject.value[e_value.BG_FOLIAGE_COLOR]
	background_water_color					= bgobject.value[e_value.BG_WATER_COLOR]
	background_fog_show						= bgobject.value[e_value.BG_FOG_SHOW]
	background_fog_sky						= bgobject.value[e_value.BG_FOG_SKY]
	background_fog_color_custom				= bgobject.value[e_value.BG_FOG_CUSTOM_COLOR]
	background_fog_color					= bgobject.value[e_value.BG_FOG_COLOR]
	background_fog_object_color_custom		= bgobject.value[e_value.BG_FOG_CUSTOM_OBJECT_COLOR]
	background_fog_object_color				= bgobject.value[e_value.BG_FOG_OBJECT_COLOR]
	background_fog_distance					= bgobject.value[e_value.BG_FOG_DISTANCE]
	background_fog_size						= bgobject.value[e_value.BG_FOG_SIZE]
	background_fog_height					= bgobject.value[e_value.BG_FOG_HEIGHT]
	background_wind							= bgobject.value[e_value.BG_WIND]
	background_wind_speed					= bgobject.value[e_value.BG_WIND_SPEED]
	background_wind_strength				= bgobject.value[e_value.BG_WIND_STRENGTH]
	background_texture_animation_speed		= bgobject.value[e_value.BG_TEXTURE_ANI_SPEED]
	
	if (background_biome = biome_list[| 0])
	{
		with (obj_resource)
			res_update_colors()

		properties.library.preview.update = true
	}
	
}

// Colors
background_night_alpha = background_sky_night_alpha()
background_sunset_alpha = background_sky_rise_set_alpha(false)
background_sunrise_alpha = background_sky_rise_set_alpha(true)
background_sunlight_color_final = merge_color(merge_color(background_sunlight_color, c_red, max(background_sunrise_alpha, background_sunset_alpha) * 0.75), c_black, background_night_alpha)
background_ambient_color_final = merge_color(background_ambient_color, background_night_color, background_night_alpha)
background_fog_color_final = background_fog_color
background_fog_object_color_final = test(background_fog_object_color_custom, background_fog_object_color, background_fog_color_final)

// Sun
background_light_data[0] = lengthdir_x(background_sunlight_range, background_sky_rotation - 90) * lengthdir_x(1, background_sky_time + 90) + cam_from[X] * background_sunlight_follow
background_light_data[1] = lengthdir_y(background_sunlight_range, background_sky_rotation - 90) * lengthdir_x(1, background_sky_time + 90) + cam_from[Y] * background_sunlight_follow
background_light_data[2] = lengthdir_z(background_sunlight_range, background_sky_time + 90)
if (background_sky_time = 0)
	background_light_data[0] += 0.1
background_light_data[3] = background_sunlight_range / 2
background_light_data[4] = color_get_red(background_sunlight_color_final) / 255
background_light_data[5] = color_get_green(background_sunlight_color_final) / 255
background_light_data[6] = color_get_blue(background_sunlight_color_final) / 255
background_light_data[7] = background_sunlight_range * 2

// Cameras
if (window_state = "export_movie")
	app_update_cameras(exportmovie_high_quality, true)
else
	app_update_cameras(view_render, false)
