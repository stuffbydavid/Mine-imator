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
		
		// Apply post scene effects (Volumetric fog, DoF, etc.)
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
		
		#region Accumulate render sample
		var expsurf, decsurf;
		render_surface_sample_expo = surface_require(render_surface_sample_expo, render_width, render_height)
		render_surface_sample_dec = surface_require(render_surface_sample_dec, render_width, render_height)
		render_surface[0] = surface_require(render_surface[0], render_width, render_height)
		render_surface[1] = surface_require(render_surface[1], render_width, render_height)
		expsurf = render_surface[0]
		decsurf = render_surface[1]
		
		// Draw temporary exponent surface
		surface_set_target(expsurf)
		{
			draw_clear_alpha(c_black, 0)
			
			if (render_sample_current != 0 && !render_samples_clear)
				draw_surface_exists(render_surface_sample_expo, 0, 0)
		}
		surface_reset_target()
		
		surface_set_target(decsurf)
		{
			draw_clear_alpha(c_black, 0)
			
			if (render_sample_current != 0 && !render_samples_clear)
				draw_surface_exists(render_surface_sample_dec, 0, 0)
		}
		surface_reset_target()
		
		// Add sample to buffer
		surface_set_target_ext(0, render_surface_sample_expo)
		surface_set_target_ext(1, render_surface_sample_dec)
		{
			render_shader_obj = shader_map[?shader_high_samples_add]
			with (render_shader_obj)
			{
				shader_set(shader)
				shader_high_samples_add_set(expsurf, decsurf)
			}
			draw_surface_exists(render_target, 0, 0)
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
			shader_high_samples_unpack_set(render_surface_sample_expo, render_surface_sample_dec, render_samples)
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
		
		surface_set_target(prevsurf)
		{
			draw_clear_alpha(c_black, 0)
			draw_surface_exists(render_target, 0, 0)
		}
		surface_reset_target()
		
		render_refresh_effects(false, true)
		prevsurf = render_post(prevsurf, false, true)
		
		surface_set_target(render_target)
		{
			draw_clear_alpha(c_black, 0)
			draw_surface_exists(prevsurf, 0, 0)
		}
		surface_reset_target()
	}
	
	// Reset TAA matrix
	taa_matrix = MAT_IDENTITY
	
	render_samples_clear = false
	
	render_time = current_time - starttime - render_surface_time
}
