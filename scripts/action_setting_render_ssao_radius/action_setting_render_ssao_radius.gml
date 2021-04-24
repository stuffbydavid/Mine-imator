/// action_setting_render_ssao_radius(value, add)
/// @arg value
/// @arg add

function action_setting_render_ssao_radius(val, add)
{
	setting_render_ssao_radius = setting_render_ssao_radius * add + val
}
