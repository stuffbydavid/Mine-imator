/// action_setting_render_subsurface_samples(value, add)
/// @arg value
/// @arg add

function action_setting_render_subsurface_samples(val, add)
{
	setting_render_subsurface_samples = setting_render_subsurface_samples * add + val
	render_samples = -1
}
