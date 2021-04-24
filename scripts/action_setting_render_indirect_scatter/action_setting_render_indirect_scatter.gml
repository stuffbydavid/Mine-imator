/// action_setting_render_indirect_scatter(value, add)
/// @arg value
/// @arg add

function action_setting_render_indirect_scatter(val, add)
{
	setting_render_indirect_scatter = setting_render_indirect_scatter * add + val / 100
	render_samples = -1
}
