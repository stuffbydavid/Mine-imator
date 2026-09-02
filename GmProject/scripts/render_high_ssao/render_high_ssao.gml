/// render_high_ssao()

function render_high_ssao()
{
	render_ssao_kernel = render_generate_sample_kernel(12)
	
	// Calculate SSAO
	render_surface[0] = surface_require(render_surface[0], render_width, render_height)
	surface_set_target(render_surface[0])
	{
		gpu_set_texrepeat(false)
		draw_clear(c_white)
		render_shader_obj = shader_map[?shader_high_ssao]
		with (render_shader_obj)
		{
			shader_set(shader)
			shader_high_ssao_set()
		}
		draw_blank(0, 0, render_width, render_height) // Blank quad
		with (render_shader_obj)
			shader_clear()
		gpu_set_texrepeat(true)
	}
	surface_reset_target()
	
	if (render_pass = e_render_pass.AO)
		render_pass_surf = surface_duplicate(render_surface[0])
	
	// Apply to shadows
	if (!render_shadows)
		render_surface_shadows = surface_require(render_surface_shadows, render_width, render_height, false, e_surface_format.rgba32float)
	
	surface_set_target(render_surface_shadows)
	{
		if (!render_shadows)
			draw_clear(c_white)
		else
			gpu_set_blendmode_ext(bm_zero, bm_src_color)
		
		draw_surface(render_surface[0], 0, 0)
		
		if (render_shadows)
			gpu_set_blendmode(bm_normal)
	}
	surface_reset_target()
}
