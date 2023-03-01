/// render_high_subsurface_scatter()

function render_high_subsurface_scatter()
{
	var ssssurf, sssrangesurf, sssblursurf;
	render_surface[0] = surface_require(render_surface[0], render_width, render_height)
	render_surface[1] = surface_require(render_surface[1], render_width, render_height)
	render_surface_hdr[0] = surface_require(render_surface_hdr[0], render_width, render_height, true, true)
	ssssurf = render_surface[0]
	sssrangesurf = render_surface[1]
	sssblursurf = render_surface_hdr[0]
	
	// Render subsurface properties
	surface_set_target_ext(0, ssssurf)
	surface_set_target_ext(1, sssrangesurf)
	{
		draw_clear_alpha(c_black, 1)
		render_world_start()
		render_world(e_render_mode.SUBSURFACE)
		render_world_done()
	}
	surface_reset_target()
	
	if ((project_render_subsurface_samples * 2) + 1 != render_subsurface_size)
	{
		render_subsurface_size = (project_render_subsurface_samples * 2) + 1
		render_subsurface_kernel = render_generate_gaussian_kernel(render_subsurface_size)
	}
	
	// Scatter blur
	surface_set_target(sssblursurf)
	{
		draw_clear(c_black)
		
		render_shader_obj = shader_map[?shader_high_subsurface_scatter]
		with (render_shader_obj)
		{
			shader_set(shader)
			shader_high_subsurface_scatter_set(ssssurf, sssrangesurf)
		}
		draw_blank(0, 0, render_width, render_height)
		with (render_shader_obj)
			shader_clear()
	}
	surface_reset_target()
	
	surface_set_target(render_surface_shadows)
	{
		draw_clear_alpha(c_black, 1)
		draw_surface_exists(sssblursurf, 0, 0)
	}
	surface_reset_target()
}
