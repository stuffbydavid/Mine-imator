/// render_world_background()
/// @desc Draws background color/image.

if (!render_background)
	return 0
	
draw_clear(background_sky_color)
if (background_image_show) // Draw image
{
	if (background_image != null && background_image_type = "image")
	{
		if (background_image_stretch)
			draw_texture(background_image.texture, 0, 0, render_width / texture_width(background_image.texture), render_height / texture_height(background_image.texture))
		else
			draw_texture(background_image.texture, 0, 0)
	}
}
else // Draw night
	draw_box(0, 0, render_width, render_height, false, hex_to_color("#020204"), background_sky_night_alpha())// * 0.95)

// Sunrise/sunset
if (background_twilight)
{
	var cam_xyangle, p, backgroundcolor;
	backgroundcolor = c_black
	cam_xyangle = point_direction(cam_from[X], cam_from[Y], cam_to[X], cam_to[Y]) - background_sky_rotation
		
	// Sunset
	p = clamp(0, 1 - abs(angle_difference_fix(cam_xyangle, 90)) / 180, 1) * .25
	backgroundcolor = merge_color(backgroundcolor, background_fog_color_final, background_sunset_alpha * p)
		
	// Sunrise
	p = clamp(0, 1 - abs(angle_difference_fix(cam_xyangle, 270)) / 180, 1) * .25
	backgroundcolor = merge_color(backgroundcolor, background_fog_color_final, background_sunrise_alpha * p)

	gpu_set_blendmode(bm_add)
	draw_box(0, 0, render_width, render_height, false, backgroundcolor, 1)
	gpu_set_blendmode(bm_normal)
}
