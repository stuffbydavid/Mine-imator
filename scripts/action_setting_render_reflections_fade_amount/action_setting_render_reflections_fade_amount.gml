/// action_setting_render_reflections_fade_amount(value, add)
/// @arg value
/// @arg add

function action_setting_render_reflections_fade_amount(val, add)
{
	setting_render_reflections_fade_amount = setting_render_reflections_fade_amount * add + val / 100
	render_samples = -1
}