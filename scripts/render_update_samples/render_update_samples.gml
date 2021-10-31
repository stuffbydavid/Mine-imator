/// render_update_samples()
/// @desc Detects if samples need to be cleared, resume, or stop

function render_update_samples()
{
	render_sample_noise_exists = false
	
	// Initialize camera for checking
	render_world_start()
	render_world_done()
	
	// Check if sampling should reset
	if (render_active != "image" && render_active != "movie")
	{
		var startpreview = (render_samples = -1 || (!array_equals(render_matrix, view_proj_matrix)) || (render_target_size[X] != render_width) || (render_target_size[Y] != render_height) ||
		(!surface_exists(render_surface_shadows) && render_shadows) ||
		(!surface_exists(render_surface_indirect) && render_indirect) ||
		(!surface_exists(render_surface_ssr) && render_reflections) ||
		(!surface_exists(render_surface_sun_volume_dec) && render_volumetric_fog));
		
		if (startpreview || render_high_preview)
		{
			render_matrix = array_copy_1d(view_proj_matrix)
			render_target_size = point2D(render_width, render_height)
			render_samples = 0
			render_samples_clear = true
			render_samples_done = false
			
			if (render_high_preview && !startpreview)
				render_high_preview = false
			else if (startpreview)
				render_high_preview = true
		}
	}
	
	// Disable AA in low-res
	if (render_high_preview && render_aa)
	{
		render_aa = false
		render_refresh_effects()
	}
	
	if (!render_samples_done)
	{
		render_samples++
		
		if (render_samples > app.project_render_samples)
		{
			render_samples_done = true
			render_samples--
		}
	}
	
	if (render_active = "image" || render_active = "movie")
	{
		render_samples_clear = false
		render_samples_done = false
		render_high_preview = false
	}
}