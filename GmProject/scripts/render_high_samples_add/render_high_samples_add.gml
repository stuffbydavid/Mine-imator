/// render_high_samples_add()

function render_high_samples_add()
{
	render_surface_samples = surface_require(render_surface_samples, render_width, render_height, false, e_surface_format.rgba32float)
	
	// Add sample to accumulation buffer
	surface_set_target(render_surface_samples)
	{
		if (render_sample_current = 0 || render_samples_clear)
			draw_clear_alpha(c_black, 0)
		
		gpu_set_blendmode_ext(bm_one, bm_one)
		draw_surface_exists(render_target, 0, 0)
		gpu_set_blendmode(bm_normal)
	}
	surface_reset_target()
}
