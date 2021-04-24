/// action_setting_render_aa_power(value, add)
/// @arg value
/// @arg add

function action_setting_render_aa_power(val, add)
{
	setting_render_aa_power = setting_render_aa_power * add + val / 100
}
