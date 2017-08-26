/// app_update_animate()
/// @desc Handles the playing of various animations. Runs once per step.

// Go through timelines
var bgobject, updatevalues;
updatevalues = (timeline_marker_previous != timeline_marker)
bgobject = null
timeline_camera = null
background_lights = 1
background_light_data[0] = 0

with (obj_timeline)
{
	// Update values
	if (updatevalues)
	{
		tl_update_values()
		tl_update_matrix()
	}
	
	if (type = "camera")
	{
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
		
		// Find camera
		if (app.timeline_camera = null && value_inherit[e_value.VISIBLE] && !hide)
			app.timeline_camera = id
			
		if (selected)
			app.timeline_camera = id
	}
	
	// Update spawner
	if (type = "particles")
		particle_spawner_update()
		
	// Find background changer
	if (type = "background" && value_inherit[e_value.VISIBLE] && !hide)
		bgobject = id
		
	// Add light
	if ((type = "pointlight" || type = "spotlight") && value_inherit[e_value.VISIBLE])
	{
		app.background_light_data[app.background_lights * 8 + 0] = world_pos[X]
		app.background_light_data[app.background_lights * 8 + 1] = world_pos[Y]
		app.background_light_data[app.background_lights * 8 + 2] = world_pos[Z]
		app.background_light_data[app.background_lights * 8 + 3] = value[e_value.LIGHT_RANGE]
		app.background_light_data[app.background_lights * 8 + 4] = color_get_red(value[e_value.LIGHT_COLOR]) / 255
		app.background_light_data[app.background_lights * 8 + 5] = color_get_green(value[e_value.LIGHT_COLOR]) / 255
		app.background_light_data[app.background_lights * 8 + 6] = color_get_blue(value[e_value.LIGHT_COLOR]) / 255
		app.background_light_data[app.background_lights * 8 + 7] = 1
		app.background_lights++
	}
}

timeline_marker_previous = timeline_marker

// Background
if (bgobject)
{
	background_sky_moon_phase			= bgobject.value[e_value.BG_SKY_MOON_PHASE]
	background_sky_time					= bgobject.value[e_value.BG_SKY_TIME]
	background_sky_rotation				= bgobject.value[e_value.BG_SKY_ROTATION]
	background_sky_clouds_speed			= bgobject.value[e_value.BG_SKY_CLOUDS_SPEED]
	background_sky_color				= bgobject.value[e_value.BG_SKY_COLOR]
	background_sky_clouds_color			= bgobject.value[e_value.BG_SKY_CLOUDS_COLOR]
	background_sunlight_color			= bgobject.value[e_value.BG_SUNLIGHT_COLOR]
	background_ambient_color			= bgobject.value[e_value.BG_AMBIENT_COLOR]
	background_night_color				= bgobject.value[e_value.BG_NIGHT_COLOR]
	background_fog_color				= bgobject.value[e_value.BG_FOG_COLOR]
	background_fog_distance				= bgobject.value[e_value.BG_FOG_DISTANCE]
	background_fog_size					= bgobject.value[e_value.BG_FOG_SIZE]
	background_fog_height				= bgobject.value[e_value.BG_FOG_HEIGHT]
	background_wind_speed				= bgobject.value[e_value.BG_WIND_SPEED]
	background_wind_strength			= bgobject.value[e_value.BG_WIND_STRENGTH]
	background_texture_animation_speed	= bgobject.value[e_value.BG_TEXTURE_ANI_SPEED]
}

// Colors
background_night_alpha = background_sky_night_alpha()
background_sunset_alpha = background_sky_rise_set_alpha(false)
background_sunrise_alpha = background_sky_rise_set_alpha(true)
background_sunlight_color_final = merge_color(merge_color(background_sunlight_color, c_red, max(background_sunrise_alpha, background_sunset_alpha) * 0.75), c_black, background_night_alpha)
background_ambient_color_final = merge_color(background_ambient_color, background_night_color, background_night_alpha)
background_fog_color_final = background_fog_color

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
app_update_cameras(view_render)
