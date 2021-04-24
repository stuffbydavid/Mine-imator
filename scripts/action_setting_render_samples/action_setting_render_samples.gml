/// action_setting_render_samples(value, add)
/// @arg value
/// @arg add

function action_setting_render_samples(val, add)
{
	var valold = setting_render_samples;
	setting_render_samples = setting_render_samples * add + val
	
	if (setting_render_samples < valold)
		render_samples = -1
}
