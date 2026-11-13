function render_high_get_realistic_warning(preset)
{
	if (!preset.has_realistic)
		return false

	var set, opt, available;
	set = preset.renderer[e_renderer.REALISTIC]
	opt = render_high_get_realistic_optimizations(set)
	available = 0
		
	if (opt[1] && set.samples > 1)
		available++
		
	if (set.shadows && set.samples > 3 && opt[0])
		available++

	// Warn sooner when fewer opt can reduce resolve time
	return (set.samples >= 24 + available * 12)
}
