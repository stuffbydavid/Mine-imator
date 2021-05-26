/// render_high_subsurface_scatter(export)

function render_high_subsurface_scatter(export)
{
	var samplestart, sampleend;
	
	// Set samples to setting
	if (!export)
	{
		if (render_samples >= project_render_samples)
		{
			render_high_subsurface_scatter_apply()
			return 0
		}
		
		samplestart = render_samples
		sampleend = render_samples + 1
	}
	else
	{
		samplestart = 0
		sampleend = project_render_samples
		render_samples = project_render_samples
	}
	
	var ssssurf, sssrangesurf, depthsurf, sssblursurf;
	render_surface[0] = surface_require(render_surface[0], render_width, render_height)
	render_surface[1] = surface_require(render_surface[1], render_width, render_height)
	render_surface[2] = surface_require(render_surface[2], render_width, render_height)
	render_surface[3] = surface_require(render_surface[3], render_width, render_height)
	render_surface_sss = surface_require(render_surface_sss, render_width, render_height)
	
	ssssurf = render_surface[0]
	sssrangesurf = render_surface[1]
	depthsurf = render_surface[2]
	sssblursurf = render_surface[3]
	
	// Render subsurface properties
	surface_set_target_ext(0, ssssurf)
	surface_set_target_ext(1, sssrangesurf)
	{
		draw_clear_alpha(c_black, 1)
		render_world_start(5000)
		render_world(e_render_mode.SUBSURFACE)
		render_world_done()
	}
	surface_reset_target()
	
	// Depth
	surface_set_target(depthsurf)
	{
		gpu_set_blendmode_ext(bm_one, bm_zero)
		
		draw_clear(c_white)
		render_world_start(5000)
		render_world(e_render_mode.DEPTH)
		render_world_done()
		
		gpu_set_blendmode(bm_normal)
	}
	surface_reset_target()
	
	if ((project_render_subsurface_samples * 2) + 1 != render_subsurface_size)
	{
		render_subsurface_size = (project_render_subsurface_samples * 2) + 1
		render_subsurface_kernel = render_generate_gaussian_kernel(render_subsurface_size)
	}
	
	for (var s = samplestart; s < sampleend; s++)
	{
		// Noise texture
		random_set_seed(s)
		
		if (export || !render_sample_noise_exists || !surface_exists(render_sample_noise_surf))
		{
			render_sample_noise_surf = surface_require(render_sample_noise_surf, render_sample_noise_size, render_sample_noise_size)
			render_generate_noise(render_sample_noise_size, render_sample_noise_size, render_sample_noise_surf, true)
			render_sample_noise_exists = true
		}
	
		// Calculate subsurface scatter
		render_surface_sample_temp1 = surface_require(render_surface_sample_temp1, render_width, render_height)
	
		// Vertical blur
		surface_set_target(render_surface_sample_temp1)
		{
			draw_clear(c_black)
		
			render_shader_obj = shader_map[?shader_high_subsurface_scatter]
			with (render_shader_obj)
			{
				shader_set(shader)
				shader_high_subsurface_scatter_set(ssssurf, sssrangesurf, depthsurf, render_surface_shadows, vec2(0, 1))
			}
			draw_blank(0, 0, render_width, render_height)
			with (render_shader_obj)
				shader_clear()
		}
		surface_reset_target()
	
		// Horizontal blur
		surface_set_target(sssblursurf)
		{
			draw_clear(c_black)
		
			render_shader_obj = shader_map[?shader_high_subsurface_scatter]
			with (render_shader_obj)
			{
				shader_set(shader)
				shader_high_subsurface_scatter_set(ssssurf, sssrangesurf, depthsurf, render_surface_sample_temp1, vec2(1, 0))
			}
			draw_blank(0, 0, render_width, render_height)
			with (render_shader_obj)
				shader_clear()
		}
		surface_reset_target()
		
		// Not exporting, quick exit
		if (!export)
		{
			surface_set_target(render_surface_shadows)
			{
				draw_clear_alpha(c_black, 1)
				draw_surface_exists(sssblursurf, 0, 0)
			}
			surface_reset_target()
			
			return 0
		}
		
		// Add sampled result
		var exptemp, dectemp;
		render_surface_sss_expo = surface_require(render_surface_sss_expo, render_width, render_height)
		render_surface_sss_dec = surface_require(render_surface_sss_dec, render_width, render_height)
		render_surface_sample_temp1 = surface_require(render_surface_sample_temp1, render_width, render_height)
		render_surface_sample_temp2 = surface_require(render_surface_sample_temp2, render_width, render_height)
		exptemp = render_surface_sample_temp1
		dectemp = render_surface_sample_temp2
		
		// Draw temporary exponent surface
		surface_set_target(exptemp)
		{
			draw_clear_alpha(c_black, 1)
			draw_surface_exists(render_surface_sss_expo, 0, 0)
			
			if (s = 0 || render_samples_clear)
				draw_clear_alpha(c_black, 1)
		}
		surface_reset_target()
		
		surface_set_target(dectemp)
		{
			draw_clear_alpha(c_black, 1)
			draw_surface_exists(render_surface_sss_dec, 0, 0)
			
			if (s = 0 || render_samples_clear)
				draw_clear_alpha(c_black, 1)
		}
		surface_reset_target()
		
		// Add reflection result to buffer
		surface_set_target_ext(0, render_surface_sss_expo)
		surface_set_target_ext(1, render_surface_sss_dec)
		{
			render_shader_obj = shader_map[?shader_high_shadows_add]
			with (render_shader_obj)
			{
				shader_set(shader)
				shader_high_shadows_add_set(exptemp, dectemp)
			}
			draw_surface_exists(sssblursurf, 0, 0)
			with (render_shader_obj)
				shader_clear()
		}
		surface_reset_target()
		
		surface_set_target(render_surface_sss)
		{
			draw_clear_alpha(c_black, 1)
			gpu_set_blendmode(bm_add)
		
			render_shader_obj = shader_map[?shader_high_samples_unpack]
			with (render_shader_obj)
			{
				shader_set(shader)
				shader_high_samples_unpack_set(render_surface_sss_expo, render_surface_sss_dec, s)
			}
			draw_blank(0, 0, render_width, render_height)
			with (render_shader_obj)
				shader_clear()
		
			gpu_set_blendmode(bm_normal)
		}
		surface_reset_target()
	}
	
	render_high_subsurface_scatter_apply()
	
	if (export)
	{
		surface_free(render_surface_sss_expo)
		surface_free(render_surface_sss_dec)
		surface_free(render_surface_sss)
		
		surface_free(render_surface_sample_temp1)
		surface_free(render_surface_sample_temp2)
	}
}

/// render_high_subsurface_scatter_apply()
function render_high_subsurface_scatter_apply()
{
	// Apply result to result surface
	if (surface_exists(render_surface_shadows))
	{
		surface_set_target(render_surface_shadows)
		{
			draw_clear_alpha(c_black, 1)
			draw_surface_exists(render_surface_sss, 0, 0)
		}
		surface_reset_target()
	}
}