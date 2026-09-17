/// render_high([singlesample])
/// @arg [singlesample]
/// @desc Renders the scene in high quality.

function render_high(singlesample = false)
{
	render_alpha_hash = render_alpha_hash_allowed && project_render_alpha_mode
	if (singlesample && renderer_current = e_renderer.REALISTIC)
	{
		ds_map_clear(render_shadow_cache_ready)
		render_gbuffers_cache_ready = false
	}
	
	var samplestart, sampleend;
	if (singlesample || renderer_current = e_renderer.STANDARD)
	{
		samplestart = 0
		sampleend = 1
	}
	else
	{
		render_update_samples()
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
	
	// Render
	for (var s = samplestart; s < sampleend; s++)
	{
		render_sample_current = s
		random_set_seed(render_sample_current)
		
		// Update random jitter
		render_high_update_jitter()
		
		// Create render passes
		render_high_create_gbuffers()
		
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
		
		// Fog
		if (background_fog_show)
			render_high_fog(finalsurf)

		finalsurf = render_high_tonemap(finalsurf)
		
		// Apply post scene effects (Glow, DoF, etc.)
		render_refresh_effects(true, false)
		finalsurf = render_post(finalsurf, true, false)

		// Finish the combined tile before assembling the all-passes grid
		if (render_pass = e_render_pass.ALL)
		{
			render_refresh_effects(false, true)
			finalsurf = render_post(finalsurf, false, true)
		}
		
		// Set target
		render_target = surface_require(render_target, render_width, render_height)
		surface_set_target(render_target)
		{
			if (render_pass = e_render_pass.ALL)
			{
				draw_clear_alpha(c_black, 1)
				render_pass_grid_draw(finalsurf)
			}
			else if (render_pass)
			{
				draw_clear_alpha(c_black, 1)
				render_pass_draw(render_pass, render_pass_surf, 0, 0, render_width, render_height)
			}
			else
			{
				draw_clear_alpha(c_black, 0)
				draw_surface_exists(finalsurf, 0, 0)
			}
		}
		surface_reset_target()
		
		if (!singlesample && renderer_current != e_renderer.STANDARD)
			render_high_samples_add()
	}
	
	if (!singlesample && renderer_current != e_renderer.STANDARD)
		render_high_samples_unpack()
	
	// Apply post effects (Bloom, color correction, etc.)
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
		
		if (app.project_render_aa && app.project_render_aa_mode = e_aa_mode.FXAA)
			prevsurf = render_high_aa(prevsurf)
		
		gpu_set_blendmode_ext(bm_one, bm_zero)
		
		surface_set_target(render_target)
		{
			draw_clear_alpha(c_black, 0)
			draw_surface_exists(prevsurf, 0, 0)
		}
		surface_reset_target()
		
		gpu_set_blendmode(bm_normal)
	}
	
	// Reset progressive AA matrix
	aa_matrix = MAT_IDENTITY
	
	if (!singlesample && renderer_current != e_renderer.STANDARD)
		render_samples_clear = false
	render_alpha_hash = false
}
