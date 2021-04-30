/// action_setting_render_reflections_precision(value, add)
/// @arg value
/// @arg add

function action_setting_render_reflections_precision(val, add)
{
	setting_render_reflections_precision = setting_render_reflections_precision * add + val / 100
	render_samples = -1
}
