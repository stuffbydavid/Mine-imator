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
}
