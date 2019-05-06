/// render_low()
/// @desc Renders the scene in low quality.

var surf;

if (!render_overlay)
{
	render_target = surface_require(render_target, render_width, render_height)
	surf = render_target
}
else
{
	render_surface[0] = surface_require(render_surface[0], render_width, render_height)
	surf = render_surface[0]
}

surface_set_target(surf)
{
	draw_clear_alpha(c_black, 0)

	// Background
	render_world_background()
	
	// World
	render_world_start()
	render_world_sky()
	render_world(test(render_lights, e_render_mode.COLOR_FOG_LIGHTS, e_render_mode.COLOR_FOG))
	render_world_done()
	
	// Alpha fix
	render_set_projection_ortho(0, 0, render_width, render_height, 0)
	gpu_set_blendmode_ext(bm_src_color, bm_one)
	if (render_background)
		draw_box(0, 0, render_width, render_height, false, c_black, 1)
	else
	{
		render_world_start()
		render_world(e_render_mode.ALPHA_FIX)
		render_world_done()
	}
	gpu_set_blendmode(bm_normal)
}
surface_reset_target()

// Apply colors
if (render_overlay)
{
	render_target = surface_require(render_target, render_width, render_height)
	surface_set_target(render_target)
	{
		draw_clear_alpha(c_black, 0)
		
		if (render_camera_colors)
		{
			render_shader_obj = shader_map[?shader_color_camera]
			with (render_shader_obj)
				shader_use()
			draw_surface_exists(render_surface[0], 0, 0)
			with (render_shader_obj)
				shader_clear()
		}
		else
			draw_surface_exists(render_surface[0], 0, 0)
		
		if (render_watermark)
			render_watermark_image()
	}
	surface_reset_target()
}