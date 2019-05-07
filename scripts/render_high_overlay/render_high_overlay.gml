/// render_high_overlay(basesurf)
/// @arg basesurf

var basesurf = argument0;

render_target = surface_require(render_target, render_width, render_height)
surface_set_target(render_target)
{
	draw_clear_alpha(c_black, 0)
	
	if (render_camera_colors)
	{
		render_shader_obj = shader_map[?shader_color_camera]
		with (render_shader_obj)
			shader_use()
		draw_surface_exists(basesurf, 0, 0)
		with (render_shader_obj)
			shader_clear()
	}
	else
		draw_surface_exists(basesurf, 0, 0)
			
	if (render_watermark)
		render_watermark_image()
}
surface_reset_target()
