/// action_setting_render_indirect_strength(value, add)
/// @arg value
/// @arg add

function action_setting_render_indirect_strength(val, add)
{
	setting_render_indirect_strength = setting_render_indirect_strength * add + val / 100
}
