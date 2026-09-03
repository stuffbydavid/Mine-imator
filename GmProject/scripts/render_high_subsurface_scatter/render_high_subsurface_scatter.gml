/// render_high_subsurface_scatter()

function render_high_subsurface_scatter()
{
	var sssblursurf;
	render_surface_hdr[0] = surface_require(render_surface_hdr[0], render_width, render_height, true, e_surface_format.rgba32float)
	sssblursurf = render_surface_hdr[0]
	
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
			shader_high_subsurface_scatter_set(render_surface_sss, render_surface_sss_range)
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
