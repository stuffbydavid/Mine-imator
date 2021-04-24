/// action_setting_render_dof_quality(value, add)
/// @arg value
/// @arg add

function action_setting_render_dof_quality(val, add)
{
	setting_render_dof_quality = setting_render_dof_quality * add + val
}
