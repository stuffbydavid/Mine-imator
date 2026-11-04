/// @desc Draws background color/image.

function render_world_background()
{
	if (!render_background)
		return 0
	
	draw_clear(env_sky_color)
	if (env_background_image_show) // Draw image
	{
		if (env_background_image != null && env_background_image_type = "image")
		{
			if (env_background_image_stretch)
				draw_texture(env_background_image.texture, 0, 0, render_width / texture_width(env_background_image.texture), render_height / texture_height(env_background_image.texture))
			else
				draw_texture(env_background_image.texture, 0, 0)
		}
	}
	else // Draw night
		draw_box(0, 0, render_width, render_height, false, env_sky_color_final, 1)// * 0.95)
	
	// Sunrise/sunset
	if (env_twilight)
	{
		var camxyangle, p, backgroundcolor;
		backgroundcolor = c_black
		camxyangle = point_direction(cam_from[X], cam_from[Y], cam_to[X], cam_to[Y]) - env_sky_rotation
		
		// Sunset
		p = clamp(0, 1 - abs(angle_difference_fix(camxyangle, 270)) / 180, 1) * .25
		backgroundcolor = merge_color(backgroundcolor, env_fog_color_final, env_sunset_alpha * p)
		
		// Sunrise
		p = clamp(0, 1 - abs(angle_difference_fix(camxyangle, 90)) / 180, 1) * .25
		backgroundcolor = merge_color(backgroundcolor, env_fog_color_final, env_sunrise_alpha * p)
		
		gpu_set_blendmode(bm_add)
		draw_box(0, 0, render_width, render_height, false, backgroundcolor, 1)
		gpu_set_blendmode(bm_normal)
	}
}
