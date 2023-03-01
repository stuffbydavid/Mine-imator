/// background_sky_update()

function background_sky_update()
{
	if (!background_fog_color_custom) // Fog color
	{
		background_fog_color_final = background_sky_color
		if (!background_image_show)
		{
			background_fog_color_final = merge_color(background_fog_color_final, merge_color(background_fog_color_final, 0, 0.95), background_night_alpha)
			background_fog_color_final = merge_color(background_fog_color_final, c_white, (1 - background_night_alpha) * 0.58)
			background_fog_color_final = merge_color(background_fog_color_final, merge_color(c_blue, c_black, 0.3), background_night_alpha * 0.05)
			
			if (background_twilight)
			{
				var cam_xyangle, p;
				cam_xyangle = point_direction(cam_from[X], cam_from[Y], cam_to[X], cam_to[Y]) - background_sky_rotation
				
				// Sunset
				p = clamp(0, 1 - abs(angle_difference_fix(cam_xyangle, 90)) / 180, 1)
				background_fog_color_final = merge_color(background_fog_color_final, merge_color(c_sunset_start, c_sunset_end, background_sunset_alpha), background_sunset_alpha * p)
				
				// Sunrise
				p = clamp(0, 1 - abs(angle_difference_fix(cam_xyangle, 270)) / 180, 1)
				background_fog_color_final = merge_color(background_fog_color_final, merge_color(c_sunset_start, c_sunset_end, background_sunrise_alpha), background_sunrise_alpha * p)
			}
		}
	}
	
	if (background_fog_custom_object_color)
		background_fog_object_color_final = background_fog_object_color
	else
		background_fog_object_color_final = background_fog_color_final
	
	// Clouds
	var alphay;
	if (background_sky_clouds_mode = "faded")
		alphay = percent(cam_from[Z], background_sky_clouds_height, background_sky_clouds_height - 250)
	else
		alphay = 1
	
	background_clouds_alpha = (background_sky_clouds_mode = "faded" ? 1 - min(background_night_alpha, 0.95) : .8 - min(background_night_alpha, 0.75)) * alphay
	background_sky_clouds_final = merge_color(background_sky_clouds_color, make_color_rgb(120, 120, 255), background_night_alpha)
	background_sky_clouds_vbuffer_pos = []
	
	var size, offset, xo, yo, num, xx, i;
	size = background_sky_clouds_size * 32
	offset = ((background_sky_clouds_speed * (background_time * 0.25 + background_sky_time * 100) + background_sky_clouds_offset) mod size)
	xo = (cam_from[X] div size) * size
	yo = (cam_from[Y] div size) * size - offset
	num = (ceil(background_fog_distance / size) + 1) * size
	xx = -num
	i = 0
	while (xx < num)
	{
		var yy = -num;
		while (yy < num)
		{
			background_sky_clouds_vbuffer_pos[i] = point3D(xx + xo, yy + yo, background_sky_clouds_height)
			i++
			yy += size
		}
		xx += size
	}
}
