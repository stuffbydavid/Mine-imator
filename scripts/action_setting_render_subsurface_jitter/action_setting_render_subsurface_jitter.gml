/// action_setting_render_subsurface_jitter(value, add)
/// @arg value
/// @arg add

function action_setting_render_subsurface_jitter(val, add)
{
	setting_render_subsurface_jitter = setting_render_subsurface_jitter * add + val / 100
	render_samples = -1
}
