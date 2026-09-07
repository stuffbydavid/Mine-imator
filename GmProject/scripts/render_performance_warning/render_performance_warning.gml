/// render_performance_warning(preset, renderer)

function render_performance_warning(preset, renderer)
{
	if (renderer = e_renderer.REALISTIC)
		return (preset.has_realistic && preset.realistic_samples >= 48)
		
	return false
}