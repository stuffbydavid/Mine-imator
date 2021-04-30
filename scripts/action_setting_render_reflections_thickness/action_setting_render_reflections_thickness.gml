/// action_setting_render_reflections_thickness(value, add)
/// @arg value
/// @arg add

function action_setting_render_reflections_thickness(val, add)
{
	setting_render_reflections_thickness = setting_render_reflections_thickness * add + val
	render_samples = -1
}
