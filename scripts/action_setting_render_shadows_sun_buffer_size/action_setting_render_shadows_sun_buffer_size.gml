/// action_setting_render_shadows_sun_buffer_size(size)
/// @arg size

if (argument0 >= 8192)
	if (!question(text_get("questionbuffersizewarning")))
		return 0

setting_render_shadows_sun_buffer_size = argument0

render_samples = -1
