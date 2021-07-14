/// render_high_reflections(export, surf)
/// @arg export
/// @arg surf
/// @desc Ray traces scene with lighting

function render_high_reflections(export, surf)
{
	var samplestart, sampleend;
	
	// Set samples to setting
	if (!export)
	{
		if (render_samples_done)
		{
			// Apply
			render_high_reflections_apply(surf)
			return 0
		}
		
		samplestart = render_samples - 1
		sampleend = render_samples
	}
	else
	{
		samplestart = 0
		sampleend = project_render_samples
		render_samples = project_render_samples
	}
	
	var ssrwidth, ssrheight, depthsurf, normalsurf, normalsurf2, materialsurf, tempsurf;
	ssrwidth = project_render_reflections_halfres ? ceil(render_width/2) : render_width
	ssrheight = project_render_reflections_halfres ? ceil(render_height/2) : render_height
	
	// Render depth & normal data
	render_surface[1] = surface_require(render_surface[1], ssrwidth, ssrheight)
	depthsurf = render_surface[1]
		
	render_surface[2] = surface_require(render_surface[2], ssrwidth, ssrheight)
	normalsurf = render_surface[2]
		
	render_surface[4] = surface_require(render_surface[4], ssrwidth, ssrheight)
	normalsurf2 = render_surface[4]
		
	render_surface[5] = surface_require(render_surface[5], ssrwidth, ssrheight)
	materialsurf = render_surface[5]
		
	surface_set_target_ext(0, depthsurf)
	surface_set_target_ext(1, normalsurf)
	surface_set_target_ext(2, normalsurf2)
	{
		draw_clear_alpha(c_white, 0)
		render_world_start(5000)
		render_world(e_render_mode.HIGH_REFLECTIONS_DEPTH_NORMAL)
		render_world_done()
	}
	surface_reset_target()
		
	// Material data
	surface_set_target(materialsurf)
	{
		draw_clear_alpha(c_white, 1)
		render_world_start(5000)
		render_world(e_render_mode.MATERIAL)
		render_world_done()
	}
	surface_reset_target()
	
	for (var s = samplestart; s < sampleend; s++)
	{
		random_set_seed(s)
		
		render_sample_noise_texture = render_get_noise_texture(s)
		
		render_indirect_kernel = render_generate_sample_kernel(16)
		
		for (var i = 0; i < 16; i++)
			render_indirect_offset[i] = random_range(0, 1)
		
		// Clear reflections
		if (s = 0 || render_samples_clear)
		{
			render_surface_ssr = surface_require(render_surface_ssr, ssrwidth, ssrheight)
			surface_set_target(render_surface_ssr)
			{
				draw_clear_alpha(app.background_sky_color_final, 1)
			}
			surface_reset_target()
		}
		
		// Temporary reflections
		render_surface[0] = surface_require(render_surface[0], ssrwidth, ssrheight)
		tempsurf = render_surface[0]
		
		// Ray trace
		surface_set_target(tempsurf)
		{
			gpu_set_texrepeat(false)
		    draw_clear_alpha(c_black, 1)
			
		    render_shader_obj = shader_map[?shader_high_reflections]
		    with (render_shader_obj)
		    {
		        shader_set(shader)
		        shader_high_reflections_set(depthsurf, normalsurf, normalsurf2, surf, materialsurf)
		    }
			
		    draw_blank(0, 0, ssrwidth, ssrheight)
			
		    with (render_shader_obj)
		        shader_clear()
			gpu_set_texrepeat(true)
		}
		surface_reset_target()
		
		var exptemp, dectemp;
		render_surface_ssr_expo = surface_require(render_surface_ssr_expo, ssrwidth, ssrheight)
		render_surface_ssr_dec = surface_require(render_surface_ssr_dec, ssrwidth, ssrheight)
		render_surface_sample_temp1 = surface_require(render_surface_sample_temp1, ssrwidth, ssrheight)
		render_surface_sample_temp2 = surface_require(render_surface_sample_temp2, ssrwidth, ssrheight)
		exptemp = render_surface_sample_temp1
		dectemp = render_surface_sample_temp2
		
		// Draw temporary exponent surface
		surface_set_target(exptemp)
		{
			draw_clear_alpha(c_black, 1)
			draw_surface_exists(render_surface_ssr_expo, 0, 0)
			
			if (s = 0 || render_samples_clear)
				draw_clear_alpha(c_black, 1)
		}
		surface_reset_target()
		
		surface_set_target(dectemp)
		{
			draw_clear_alpha(c_black, 1)
			draw_surface_exists(render_surface_ssr_dec, 0, 0)
			
			if (s = 0 || render_samples_clear)
				draw_clear_alpha(c_black, 1)
		}
		surface_reset_target()
		
		// Add reflection result to buffer
		surface_set_target_ext(0, render_surface_ssr_expo)
		surface_set_target_ext(1, render_surface_ssr_dec)
		{
			render_shader_obj = shader_map[?shader_high_shadows_add]
			with (render_shader_obj)
			{
				shader_set(shader)
				shader_high_shadows_add_set(exptemp, dectemp)
			}
			draw_surface_exists(tempsurf, 0, 0)
			with (render_shader_obj)
				shader_clear()
		}
		surface_reset_target()
		
		surface_set_target(render_surface_ssr)
		{
			draw_clear_alpha(c_black, 1)
			gpu_set_blendmode(bm_add)
		
			render_shader_obj = shader_map[?shader_high_samples_unpack]
			with (render_shader_obj)
			{
				shader_set(shader)
				shader_high_samples_unpack_set(render_surface_ssr_expo, render_surface_ssr_dec, render_samples)
			}
			draw_blank(0, 0, ssrwidth, ssrheight)
			with (render_shader_obj)
				shader_clear()
		
			gpu_set_blendmode(bm_normal)
		}
		surface_reset_target()
	}
	
	if (export)
	{
		surface_free(render_surface_ssr_expo)
		surface_free(render_surface_ssr_dec)
		
		surface_free(render_surface_sample_temp1)
		surface_free(render_surface_sample_temp2)
	}
	
	// Apply reflections
	render_high_reflections_apply(surf)
}

/// render_high_reflections_apply(surf)
/// @arg surf
function render_high_reflections_apply(surf)
{
	// Material data
	render_surface[2] = surface_require(render_surface[2], render_width, render_height)
	var materialsurf = render_surface[2];
	surface_set_target(materialsurf)
	{
		draw_clear_alpha(c_white, 1)
		render_world_start(5000)
		render_world(e_render_mode.MATERIAL)
		render_world_done()
	}
	surface_reset_target()
	
	// Apply reflections
	render_surface[1] = surface_require(render_surface[1], render_width, render_height)
	var applysurf = render_surface[1];
	
	surface_set_target(applysurf)
	{
		draw_clear_alpha(c_black, 0)
		
		render_shader_obj = shader_map[?shader_high_reflections_apply]
		with (render_shader_obj)
		{
			shader_set(shader)
			shader_high_reflections_apply_set(render_surface_ssr, materialsurf)
		}
		
		draw_surface_exists(surf, 0, 0)
		with (render_shader_obj)
			shader_clear()
	}
	surface_reset_target()
	
	// Apply result to result surface
	if (surface_exists(surf))
	{
		surface_set_target(surf)
		{
			draw_clear_alpha(c_black, 0)
			draw_surface_exists(applysurf, 0, 0)
		}
		surface_reset_target()
	}
}