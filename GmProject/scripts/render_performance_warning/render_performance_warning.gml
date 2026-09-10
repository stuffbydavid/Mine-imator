/// render_performance_warning(preset, renderer)

function render_performance_warning(preset, renderer)
{
	if (renderer = e_renderer.REALISTIC)
		return (preset.has_realistic && preset.renderer[e_renderer.REALISTIC].samples >= 48)
		
	return false
}
