/// action_setting_render_samples(value, add)
/// @arg value
/// @arg add

var valold = setting_render_samples;

setting_render_samples = setting_render_samples * argument1 + argument0


if (setting_render_samples < valold)
	render_samples = -1
