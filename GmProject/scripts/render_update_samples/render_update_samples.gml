/// render_update_samples()
/// @desc Detects if samples need to be cleared, resume, or stop

function render_update_samples()
{
	//render_sample_noise_exists = false
	
	// Initialize camera for checking
	render_world_start()
	render_world_done()
	
	// Update PCSS samples
	var qualitychanged = render_update_pcss_kernel()

	// Check if sampling should reset
	var refresh = (render_samples = -1 ||
		qualitychanged ||
		(!matrix_equals(render_matrix, view_proj_matrix)) ||
		(render_target_size[X] != render_width) ||
		(render_target_size[Y] != render_height) ||
		!surface_exists(render_surface_samples));
	
	if (refresh)
	{
		render_gbuffers_cache_ready = false
		ds_map_clear(render_shadow_cache_ready)
		render_matrix = array_copy_1d(view_proj_matrix)
		render_target_size = point2D(render_width, render_height)
		render_samples = 0
		render_samples_clear = true
		render_samples_done = false
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
}
