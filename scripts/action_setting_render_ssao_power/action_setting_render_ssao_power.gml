/// action_setting_render_ssao_power(value, add)
/// @arg value
/// @arg add

function action_setting_render_ssao_power(val, add)
{
	setting_render_ssao_power = setting_render_ssao_power * add + val / 100
}
