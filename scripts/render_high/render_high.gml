/// render_high()
/// @desc Renders scene in high quality.

function render_high()
{
	var starttime;
	
	starttime = current_time
	render_surface_time = 0
	render_update_samples()
	
	var samplestart, sampleend;
	
	if (render_active != "image" && render_active != "movie")
	{	
		if (render_samples_done)
		{
			samplestart = 0
			sampleend = 0
		}
		else
		{
			samplestart = render_samples - 1
			sampleend = render_samples
		}
	}
	else
	{
		samplestart = 0
		sampleend = project_render_samples
		render_samples = project_render_samples
	}
	
	// Render
	for (var s = samplestart; s < sampleend; s++)
	{
		render_sample_current = s
		
		// Update TAA jitter
		render_high_update_taa()
		
		// SSAO
		if (render_ssao)
			render_high_ssao()
		
		// Shadows
		if (render_shadows)
			render_high_shadows()
		
		// Indirect lighting
		if (render_indirect)
			render_high_indirect()
		
		// Composite current effects onto the scene
		var finalsurf;
		finalsurf = render_high_scene(render_surface_ssao, render_surface_shadows)
		
		// Reflections
		if (render_reflections)
			render_high_reflections(finalsurf)
		
		// Minecraft fog
		if (background_fog_show)
			render_high_fog(finalsurf)
		
		// Apply post scene effects (Glow, DoF, etc.)
		render_refresh_effects(true, false)
		finalsurf = render_post(finalsurf, true, false)
		
		// Set target
		render_target = surface_require(render_target, render_width, render_height)
		surface_set_target(render_target)
		{
			if (render_pass)
			{
				draw_clear_alpha(c_black, 1)
				draw_surface_exists(render_pass_surf, 0, 0)
			}
			else
			{
				draw_clear_alpha(c_black, 0)
				draw_surface_exists(finalsurf, 0, 0)
			}
		}
		surface_reset_target()
		
		// Apply post effects
		
		
		#region Accumulate render sample
		var expsurf, decsurf, alphasurf;
		render_surface_sample_expo = surface_require(render_surface_sample_expo, render_width, render_height)
		render_surface_sample_dec = surface_require(render_surface_sample_dec, render_width, render_height)
		render_surface_sample_alpha = surface_require(render_surface_sample_alpha, render_width, render_height)
		render_surface[0] = surface_require(render_surface[0], render_width, render_height)
		render_surface[1] = surface_require(render_surface[1], render_width, render_height)
		render_surface[2] = surface_require(render_surface[2], render_width, render_height)
		expsurf = render_surface[0]
		decsurf = render_surface[1]
		alphasurf = render_surface[2]
		
		// Draw temporary surfaces
		surface_set_target_ext(0, expsurf)
		surface_set_target_ext(1, decsurf)
		surface_set_target_ext(2, alphasurf)
		{
			draw_clear_alpha(c_black, 0)
		}
		surface_reset_target()
		
		if (render_sample_current != 0 && !render_samples_clear)
		{
			surface_copy(expsurf, 0, 0, render_surface_sample_expo)
			surface_copy(decsurf, 0, 0, render_surface_sample_dec)
			surface_copy(alphasurf, 0, 0, render_surface_sample_alpha)
		}
		
		// Add sample to buffer
		surface_set_target_ext(0, render_surface_sample_expo)
		surface_set_target_ext(1, render_surface_sample_dec)
		surface_set_target_ext(2, render_surface_sample_alpha)
		{
			draw_clear_alpha(c_black, 0)
			
			render_shader_obj = shader_map[?shader_high_samples_add]
			with (render_shader_obj)
			{
				shader_set(shader)
				shader_high_samples_add_set(expsurf, decsurf, alphasurf, render_target)
			}
			draw_blank(0, 0, render_width, render_height)
			with (render_shader_obj)
				shader_clear()
		}
		surface_reset_target()
		
		#endregion
	}
	
	// Unpack render from sample data
	surface_set_target(render_target)
	{
		draw_clear_alpha(c_black, 0)
		
		render_shader_obj = shader_map[?shader_high_samples_unpack]
		with (render_shader_obj)
		{
			shader_set(shader)
			shader_high_samples_unpack_set(render_surface_sample_expo, render_surface_sample_dec, render_surface_sample_alpha, render_samples)
		}
		draw_blank(0, 0, render_width, render_height)
		with (render_shader_obj)
			shader_clear()
	}
	surface_reset_target()
	
	// Apply post effects (Bloom, color correction, etc.)
	if (!render_pass)
	{
		var prevsurf;
		render_surface[3] = surface_require(render_surface[3], render_width, render_height)
		prevsurf = render_surface[3]
		
		gpu_set_blendmode_ext(bm_one, bm_zero)
		
		surface_set_target(prevsurf)
		{
			draw_clear_alpha(c_black, 0)
			draw_surface_exists(render_target, 0, 0)
		}
		surface_reset_target()
		
		gpu_set_blendmode(bm_normal)
		
		render_refresh_effects(false, true)
		prevsurf = render_post(prevsurf, false, true)
		
		gpu_set_blendmode_ext(bm_one, bm_zero)
		
		surface_set_target(render_target)
		{
			draw_clear_alpha(c_black, 0)
			draw_surface_exists(prevsurf, 0, 0)
		}
		surface_reset_target()
		
		gpu_set_blendmode(bm_normal)
	}
	
	// Reset TAA matrix
	taa_matrix = MAT_IDENTITY
	
	render_samples_clear = false
	
	render_time = current_time - starttime - render_surface_time
}
