/// action_setting_render_glow_radius(value, add)
/// @arg value
/// @arg add

function action_setting_render_glow_radius(val, add)
{
	setting_render_glow_radius = setting_render_glow_radius * add + val / 100
}
