/// @desc Updates the PCSS sample kernel for the active renderer, returns whether the quality changed.

function render_update_pcss_kernel()
{
	var shadowquality, qualitychanged;
	shadowquality = app.project_render_shadows_jittered ? 0 : clamp(floor(app.project_render_shadows_blur_quality), 0, 64)
	qualitychanged = shadowquality != render_pcss_quality_prev
	
	if (qualitychanged)
	{
		var blockersamples = clamp(floor((shadowquality + 1) / 2), 4, 16);
		render_pcss_kernel = render_generate_progressive_disk_samples(max(shadowquality, blockersamples), 0)
		render_pcss_quality_prev = shadowquality
	}

	return qualitychanged
}
