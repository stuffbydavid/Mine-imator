/// render_high_ssao()

function render_high_ssao()
{
	// Calculate SSAO
	render_surface_ssao = surface_require(render_surface_ssao, render_width, render_height)
	surface_set_target(render_surface_ssao)
	{
		gpu_set_texrepeat(false)
		draw_clear(c_white)
		render_shader_obj = shader_map[?shader_high_ssao]
		with (render_shader_obj)
		{
			shader_set(shader)
			shader_high_ssao_set(render_surface_depth, render_surface_normal_ext, render_surface_emissive)
		}
		draw_blank(0, 0, render_width, render_height) // Blank quad
		with (render_shader_obj)
			shader_clear()
		gpu_set_texrepeat(true)
	}
	surface_reset_target()
	
	// Blur
	repeat (project_render_ssao_blur_passes)
	{
		var ssaosurftemp;
		render_surface[0] = surface_require(render_surface[0], render_width, render_height)
		ssaosurftemp = render_surface[0]
		
		render_shader_obj = shader_map[?shader_high_ssao_blur]
		with (render_shader_obj)
			shader_set(shader)
		
		// Horizontal
		surface_set_target(ssaosurftemp)
		{
			with (render_shader_obj)
				shader_high_ssao_blur_set(render_surface_depth, render_surface_normal_ext, 1, 0)
			draw_surface_exists(render_surface_ssao, 0, 0)
		}
		surface_reset_target()
		
		// Vertical
		surface_set_target(render_surface_ssao)
		{
			with (render_shader_obj)
				shader_high_ssao_blur_set(render_surface_depth, render_surface_normal_ext, 0, 1)
			draw_surface_exists(ssaosurftemp, 0, 0)
		}
		surface_reset_target()
		
		with (render_shader_obj)
			shader_clear()
	}
	gpu_set_texrepeat(true)
	
	if (render_pass = e_render_pass.AO)
		render_pass_surf = surface_duplicate(render_surface_ssao)
	
	return render_surface_ssao
}
