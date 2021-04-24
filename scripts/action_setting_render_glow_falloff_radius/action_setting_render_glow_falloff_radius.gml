/// action_setting_render_glow_falloff_radius(value, add)
/// @arg value
/// @arg add

function action_setting_render_glow_falloff_radius(val, add)
{
	setting_render_glow_falloff_radius = setting_render_glow_falloff_radius * add + val / 100
}
