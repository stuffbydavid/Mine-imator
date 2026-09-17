/// render_optimizations_state(settings)
/// @arg settings
/// @desc Returns the effective light buffer, data buffer, and single sample shadow optimizations.

function render_optimizations_state(settings)
{
	var single = settings.shadows_single_sample
	var data = settings.cache_data_buffers || single
	var light = settings.cache_light_buffers && !single
	return [light, data, single]
}
