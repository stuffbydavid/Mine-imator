/// @desc Returns the available light and data buffer optimizations.

function render_high_get_realistic_optimizations(settings)
{
	var light, data;
	light = (!settings.shadows_transparent && !settings.shadows_jittered)
	data = ((!settings.aa || settings.aa_mode = e_aa_mode.FXAA) && !settings.shadows_transparent)
	
	return [ light, data ]
}
