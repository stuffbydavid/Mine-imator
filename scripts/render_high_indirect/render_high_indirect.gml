/// render_high_indirect()
/// @desc Ray traces shadow surf for light bounces, returns indirect lighting buffer

function render_high_indirect()
{
	var tempsurf, tempsurf2;
	render_surface_indirect = surface_require(render_surface_indirect, render_width, render_height)
	render_surface[0] = surface_require(render_surface[0], render_width, render_height)
	render_surface[1] = surface_require(render_surface[1], render_width, render_height)
	tempsurf = render_surface[0]
	tempsurf2 = render_surface[1]
	
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
		    shader_high_raytrace_uv_set(render_surface_depth, render_surface_normal, render_surface_normal_ext)
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
		    shader_high_raytrace_indirect_set(tempsurf, tempsurf2, render_surface_shadows, render_surface_diffuse, render_surface_normal, render_surface_normal_ext, render_surface_depth)
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
		render_surface[0] = surface_require(render_surface[0], render_width, render_height)
		indirectsurftemp = render_surface[0]
		
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
				shader_high_indirect_blur_set(render_surface_depth, render_surface_normal_ext)
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
