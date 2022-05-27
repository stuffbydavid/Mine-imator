/// render_high_indirect(export)
/// @arg export
/// @desc Ray traces shadow surf for light bounces, returns indirect lighting buffer

function render_high_indirect(export)
{
	var samplestart, sampleend;
	
	// Set samples to setting
	if (!export)
	{
		if (render_samples_done)
			return 0
		
		samplestart = render_samples - 1
		sampleend = render_samples
	}
	else
	{
		samplestart = 0
		sampleend = project_render_samples
		render_samples = project_render_samples
	}
	
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
	
	for (var s = samplestart; s < sampleend; s++)
	{
		// Noise texture
		random_set_seed(s)
		
		render_sample_noise_texture = render_get_noise_texture(s)
		
		if (s = 0 || render_samples_clear)
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
		
		var exptemp, dectemp;
		render_surface_indirect_expo = surface_require(render_surface_indirect_expo, render_width, render_height)
		render_surface_indirect_dec = surface_require(render_surface_indirect_dec, render_width, render_height)
		render_surface_sample_temp1 = surface_require(render_surface_sample_temp1, render_width, render_height)
		render_surface_sample_temp2 = surface_require(render_surface_sample_temp2, render_width, render_height)
		exptemp = render_surface_sample_temp1
		dectemp = render_surface_sample_temp2
		
		// Draw temporary exponent surface
		surface_set_target(exptemp)
		{
			draw_clear_alpha(c_black, 1)
			draw_surface_exists(render_surface_indirect_expo, 0, 0)
			
			if (s = 0 || render_samples_clear)
				draw_clear_alpha(c_black, 1)
		}
		surface_reset_target()
		
		surface_set_target(dectemp)
		{
			draw_clear_alpha(c_black, 1)
			draw_surface_exists(render_surface_indirect_dec, 0, 0)
			
			if (s = 0 || render_samples_clear)
				draw_clear_alpha(c_black, 1)
		}
		surface_reset_target()
		
		// Add light shadow to buffer
		surface_set_target_ext(0, render_surface_indirect_expo)
		surface_set_target_ext(1, render_surface_indirect_dec)
		{
			render_shader_obj = shader_map[?shader_high_samples_add]
			with (render_shader_obj)
			{
				shader_set(shader)
				shader_high_samples_add_set(exptemp, dectemp)
			}
			draw_surface_exists(render_surface_indirect, 0, 0)
			with (render_shader_obj)
				shader_clear()
		}
		surface_reset_target()
	}
	
	surface_set_target(render_surface_indirect)
	{
		draw_clear_alpha(c_black, 1)
		gpu_set_blendmode(bm_add)
		
		render_shader_obj = shader_map[?shader_high_samples_unpack]
		with (render_shader_obj)
		{
			shader_set(shader)
			shader_high_samples_unpack_set(render_surface_indirect_expo, render_surface_indirect_dec, render_samples)
		}
		draw_blank(0, 0, render_width, render_height)
		with (render_shader_obj)
			shader_clear()
		
		gpu_set_blendmode(bm_normal)
	}
	surface_reset_target()
	
	if (export)
	{
		surface_free(render_surface_indirect_expo)
		surface_free(render_surface_indirect_dec)
		
		surface_free(render_surface_sample_temp1)
		surface_free(render_surface_sample_temp2)
	}
}
