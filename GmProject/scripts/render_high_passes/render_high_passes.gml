/// render_high_passes()
/// @arg Creates render passes for use re-used data in more complex effects.

function render_high_passes()
{
	render_surface_diffuse = surface_require(render_surface_diffuse, render_width, render_height)
	render_surface_emissive = surface_require(render_surface_emissive, render_width, render_height)
	render_surface_material = surface_require(render_surface_material, render_width, render_height)
	render_surface_specular = surface_require(render_surface_specular, render_width, render_height, false, true)
	
	if (render_depth_normals)
	{
		render_surface_depth = surface_require(render_surface_depth, render_width, render_height)
		render_surface_normal = surface_require(render_surface_normal, render_width, render_height, true, true)
	}
	
	// Clear specular
	surface_set_target(render_surface_specular)
	{
		draw_clear_alpha(c_black, 1)
	}
	surface_reset_target()
	
	// Diffuse data
	surface_set_target(render_surface_diffuse)
	{
		// Background
		draw_clear_alpha(c_black, 0)
		render_world_background()
		
		// World
		render_world_start()
		render_world_sky()
		render_world(e_render_mode.COLOR)
		render_world_done()
		
		// 2D mode
		render_set_projection_ortho(0, 0, render_width, render_height, 0)
		
		// Alpha fix
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
	
	// Depth, normals
	if (render_depth_normals)
	{
		surface_set_target_ext(0, render_surface_depth)
		surface_set_target_ext(1, render_surface_normal)
		{
			gpu_set_blendmode_ext(bm_one, bm_zero)
		
			draw_clear_alpha(c_black, 0)
			render_world_start(depth_far)
			render_world(e_render_mode.HIGH_DEPTH_NORMAL)
			render_world_done()
		
			gpu_set_blendmode(bm_normal)
		}
		surface_reset_target()
	}
	
	// Material passes
	surface_set_target_ext(0, render_surface_material)
	surface_set_target_ext(1, render_surface_emissive)
	{
		draw_clear(c_black)
		render_world_start()
		render_world(e_render_mode.MATERIAL)
		render_world_done()
	}
	surface_reset_target()
	
	// Noise
	render_sample_noise_texture = render_get_noise_texture(render_sample_current)
	
	if (render_pass = e_render_pass.DIFFUSE)
		render_pass_surf = surface_duplicate(render_surface_diffuse)
	
	if (render_pass = e_render_pass.MATERIAL)
		render_pass_surf = surface_duplicate(render_surface_material)
	
	if (render_pass = e_render_pass.DEPTH_U24)
		render_pass_surf = surface_duplicate(render_surface_depth)
	
	if (render_pass = e_render_pass.NORMAL)
		render_pass_surf = surface_duplicate(render_surface_normal)
}