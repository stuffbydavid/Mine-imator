/// render_performance_warning(preset, renderer)

function render_performance_warning(preset, renderer)
{
	if (renderer = e_renderer.REALISTIC)
	{
		if (!preset.has_realistic)
			return false

		var settings = preset.renderer[e_renderer.REALISTIC]
		var optimizations = render_optimizations_state(settings)
		var available = 0
		if (optimizations[1] && settings.samples > 1)
			available++
		if (settings.shadows && settings.samples > 3 && (optimizations[0] || optimizations[2]))
			available++

		// Warn sooner when fewer optimizations can reduce resolve time
		return settings.samples >= 24 + available * 12
	}
		
	return false
}
