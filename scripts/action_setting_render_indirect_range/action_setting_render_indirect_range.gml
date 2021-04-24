/// action_setting_render_indirect_range(value, add)
/// @arg value
/// @arg add

function action_setting_render_indirect_range(val, add)
{
	setting_render_indirect_range = setting_render_indirect_range * add + val
	render_samples = -1
}
