/// background_sky_update()

if (!background_fog_color_custom) // Fog color
{
	background_fog_color_final = background_sky_color
	if (!background_image_show)
	{
		background_fog_color_final = merge_color(background_fog_color_final, merge_color(background_fog_color_final, 0, 0.95), background_night_alpha)
		background_fog_color_final = merge_color(background_fog_color_final, c_white, (1 - background_night_alpha) * 0.4)
		background_fog_color_final = merge_color(background_fog_color_final, merge_color(c_blue, c_black, 0.3), background_night_alpha * 0.05)
		
		var cam_xyangle, p;
		cam_xyangle = point_direction(cam_from[X], cam_from[Y], cam_to[X], cam_to[Y]) - background_sky_rotation
		
		// Sunset
		p = clamp(0, 1 - abs(angle_difference_fix(cam_xyangle, 90)) / 180, 1)
		background_fog_color_final = merge_color(background_fog_color_final, merge_color(c_sunset_start, c_sunset_end, background_sunset_alpha), background_sunset_alpha * p)
		
		// Sunrise
		p = clamp(0, 1 - abs(angle_difference_fix(cam_xyangle, 270)) / 180, 1)
		background_fog_color_final = merge_color(background_fog_color_final, merge_color(c_sunset_start, c_sunset_end, background_sunrise_alpha), background_sunrise_alpha * p)
	}
	
	if (!background_fog_object_color_custom)
		background_fog_object_color_final = background_fog_color_final
	
}

// Sun position
background_sky_update_sun()
