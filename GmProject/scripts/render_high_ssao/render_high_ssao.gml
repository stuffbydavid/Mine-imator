/// render_high_ssao()

function render_high_ssao()
{
	render_ssao_kernel = render_generate_sample_kernel(12)
	
	// Render mask
	render_surface[2] = surface_require(render_surface[2], render_width, render_height)
	surface_set_target(render_surface[2])
	{
		draw_clear(c_black)
		render_world_start()
		render_world(e_render_mode.AO_MASK)
		render_world_done()
		
		// 2D mode
		render_set_projection_ortho(0, 0, render_width, render_height, 0)
		
		// Alpha fix
		gpu_set_blendmode_ext(bm_src_color, bm_one) 
		draw_box(0, 0, render_width, render_height, false, c_black, 1)
		gpu_set_blendmode(bm_normal)
	}
	surface_reset_target()
	
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
			shader_high_ssao_set(render_surface[2])
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
		render_surface_shadows = surface_require(render_surface_shadows, render_width, render_height, false, true)
	
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
