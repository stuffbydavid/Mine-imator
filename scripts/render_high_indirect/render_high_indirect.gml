/// render_high_indirect()
/// @desc Ray traces shadow surf for light bounces, returns indirect lighting buffer

function render_high_indirect()
{
	var shadowsurf, tempsurf, tempsurf2, depthsurf, normalsurf, normalsurf2, diffusesurf;
	shadowsurf = render_surface_shadows
	
	render_surface_indirect = surface_require(render_surface_indirect, render_width, render_height)
	
	render_surface[0] = surface_require(render_surface[0], render_width, render_height)
	render_surface[1] = surface_require(render_surface[1], render_width, render_height)
	render_surface[2] = surface_require(render_surface[2], render_width, render_height)
	render_surface[3] = surface_require(render_surface[3], render_width, render_height)
	render_surface[4] = surface_require(render_surface[4], render_width, render_height)
	render_surface[5] = surface_require(render_surface[5], render_width, render_height)
	
	tempsurf = render_surface[0]
	tempsurf2 = render_surface[1]
	depthsurf = render_surface[2]
	normalsurf = render_surface[3]
	normalsurf2 = render_surface[4]
	diffusesurf = render_surface[5]
	
	// Render diffuse color
	surface_set_target(diffusesurf)
	{
		// Background
		draw_clear_alpha(c_black, 0)
		render_world_background()
		
		// World
		render_world_start()
		render_world_sky()
		render_world(e_render_mode.COLOR_FOG)
		render_world_done()
	}
	surface_reset_target()
	
	// Render depth & normal data
	surface_set_target_ext(0, depthsurf)
	surface_set_target_ext(1, normalsurf)
	surface_set_target_ext(2, normalsurf2)
	surface_set_target_ext(3, render_surface_indirect)
	{
		draw_clear_alpha(c_white, 0)
		render_world_start(5000)
		render_world(e_render_mode.HIGH_INDIRECT_DEPTH_NORMAL)
		render_world_done()
	}
	surface_reset_target()
	
	// Noise texture
	random_set_seed(render_sample_current)
	
	render_sample_noise_texture = render_get_noise_texture(render_sample_current)
	
	if (render_sample_current = 0 || render_samples_clear)
	{
		surface_set_target(render_surface_indirect)
		{
			draw_clear_alpha(c_black, 1)
		}
		surface_reset_target()
	}
	
	// Raytrace indirect
	surface_set_target_ext(0, tempsurf)
	surface_set_target_ext(1, tempsurf2)
	{
		gpu_set_texrepeat(false)
		draw_clear_alpha(c_black, 0)
		
		render_shader_obj = shader_map[?shader_high_raytrace_uv]
		with (render_shader_obj)
		{
		    shader_set(shader)
		    shader_high_raytrace_uv_set(depthsurf, normalsurf, normalsurf2)
		}
		
		draw_blank(0, 0, render_width, render_height)
		
		with (render_shader_obj)
		    shader_clear()
		gpu_set_texrepeat(true)
	}
	surface_reset_target()
	
	// Resolve RT data to color
	surface_set_target(render_surface_indirect)
	{
		gpu_set_texrepeat(false)
		draw_clear_alpha(c_black, 0)
		
		render_shader_obj = shader_map[?shader_high_raytrace_indirect]
		with (render_shader_obj)
		{
		    shader_set(shader)
		    shader_high_raytrace_indirect_set(tempsurf, tempsurf2, shadowsurf, diffusesurf, normalsurf, normalsurf2, depthsurf)
		}
		
		draw_blank(0, 0, render_width, render_height)
		
		with (render_shader_obj)
		    shader_clear()
		gpu_set_texrepeat(true)
	}
	surface_reset_target()
	
	// Blur result
	if (app.project_render_indirect_blur_radius > 0)
	{
		var indirectsurftemp;
		render_surface[6] = surface_require(render_surface[6], render_width, render_height)
		indirectsurftemp = render_surface[6]
		
		surface_set_target(indirectsurftemp)
		{
			draw_clear_alpha(c_black, 0)
			draw_surface_exists(render_surface_indirect, 0, 0)
		}
		surface_reset_target()
		
		render_shader_obj = shader_map[?shader_high_indirect_blur]
		with (render_shader_obj)
			shader_set(shader)
		
		surface_set_target(render_surface_indirect)
		{
			draw_clear_alpha(c_black, 0)
			with (render_shader_obj)
				shader_high_indirect_blur_set(depthsurf, normalsurf2)
			draw_surface_exists(indirectsurftemp, 0, 0)
		}
		surface_reset_target()
		
		with (render_shader_obj)
			shader_clear()
		
		gpu_set_texrepeat(true)
	}
	
	// Render pass
	if (render_pass = e_render_pass.INDIRECT || render_pass = e_render_pass.INDIRECT_SHADOWS) 
	{
		// Add direct lighting
		if (render_pass = e_render_pass.INDIRECT_SHADOWS)
		{
			surface_set_target(render_pass_surf)
			{
				render_shader_obj = shader_map[?shader_add]
				with (render_shader_obj)
				{
					shader_set(shader)
					shader_add_set(render_surface_indirect, app.project_render_indirect_strength, c_white)
				}
				draw_surface_exists(render_surface_shadows, 0, 0)
				with (render_shader_obj)
					shader_clear()
			}
			surface_reset_target()
		}
		else
			render_pass_surf = surface_duplicate(render_surface_indirect)
	}
}
