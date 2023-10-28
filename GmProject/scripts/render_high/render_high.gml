/// render_high()
/// @desc Renders the scene in high quality.

function render_high()
{
	var starttime, samplestart, sampleend;
	
	starttime = current_time
	render_surface_time = 0
	render_update_samples()
	
	render_alpha_hash = project_render_alpha_mode
	
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
	
	// Render
	for (var s = samplestart; s < sampleend; s++)
	{
		render_sample_current = s
		random_set_seed(render_sample_current)
		
		// Update TAA jitter
		render_high_update_taa()
		
		// Create render passes
		render_high_passes()
		
		// Shadows
		if (render_shadows)
			render_high_shadows()
		
		// Indirect lighting
		if (render_indirect)
			render_high_indirect()
		
		// SSAO
		if (render_ssao)
			render_high_ssao()
		
		// Composite current effects, avoid render surf 0 going forward
		var finalsurf;
		finalsurf = render_high_scene()
		
		// Reflections
		if (render_reflections)
			render_high_reflections(finalsurf)
		
		finalsurf = render_high_tonemap(finalsurf)
		
		// Minecraft fog
		if (background_fog_show)
			render_high_fog(finalsurf)
		
		// Apply post scene effects (DoF, etc.)
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
		
		render_high_samples_add()
	}
	
	render_high_samples_unpack()
	
	// Apply post effects (Bloom, glow, color correction, etc.)
	if (!render_pass)
	{
		var prevsurf;
		render_surface[0] = surface_require(render_surface[0], render_width, render_height)
		prevsurf = render_surface[0]
		
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
	render_alpha_hash = false
	
	render_time = current_time - starttime - render_surface_time
}
