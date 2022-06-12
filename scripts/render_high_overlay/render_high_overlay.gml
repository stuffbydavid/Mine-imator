/// render_high_overlay(basesurf)
/// @arg basesurf

function render_high_overlay(prevsurf)
{
	var resultsurf = render_high_get_apply_surf();
	
	surface_set_target(resultsurf)
	{
		draw_clear_alpha(c_black, 0)
		
		if (render_camera_colors)
		{
			render_shader_obj = shader_map[?shader_color_camera]
			with (render_shader_obj)
				shader_use()
			draw_surface_exists(prevsurf, 0, 0)
			with (render_shader_obj)
				shader_clear()
		}
		else
			draw_surface_exists(prevsurf, 0, 0)
		
		if (render_watermark)
			render_watermark_image()
	}
	surface_reset_target()
	
	return resultsurf
}
