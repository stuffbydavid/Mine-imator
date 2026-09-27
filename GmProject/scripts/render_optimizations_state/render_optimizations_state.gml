/// render_optimizations_state(settings)
/// @arg settings
/// @desc Returns the available light and data buffer optimizations.

function render_optimizations_state(settings)
{
	var light = !settings.shadows_transparent && !settings.shadows_jittered
	var data = (!settings.aa || settings.aa_mode = e_aa_mode.FXAA) && !settings.shadows_transparent
	return [light, data]
}
