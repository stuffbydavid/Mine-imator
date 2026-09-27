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
	
	for (var i = 0; i < app.project_render_ssao_blur_passes; i++)
	{
		render_surface[1] = surface_require(render_surface[1], render_width, render_height)
		render_shader_obj = shader_map[?shader_high_ssao_blur]
		with (render_shader_obj)
			shader_set(shader)

		// Horizontal
		surface_set_target(render_surface[1])
		{
			draw_clear(c_white)
			with (render_shader_obj)
				shader_high_ssao_blur_set(1, 0)
			draw_surface_exists(render_surface[0], 0, 0)
		}
		surface_reset_target()

		// Vertical
		surface_set_target(render_surface[0])
		{
			draw_clear(c_white)
			with (render_shader_obj)
				shader_high_ssao_blur_set(0, 1)
			draw_surface_exists(render_surface[1], 0, 0)
		}
		surface_reset_target()

		with (render_shader_obj)
			shader_clear()
	}

	render_pass_capture(e_render_pass.AO, render_surface[0])
}
