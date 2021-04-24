/// action_setting_render_indirect_blur_passes(value, add)
/// @arg value
/// @arg add

function action_setting_render_indirect_blur_passes(val, add)
{
	setting_render_indirect_blur_passes = setting_render_indirect_blur_passes * add + val
	render_samples = -1
}
