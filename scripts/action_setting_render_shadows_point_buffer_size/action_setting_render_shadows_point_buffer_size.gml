/// action_setting_render_shadows_point_buffer_size(size)
/// @arg size

if (argument0 >= 4096)
	if (!question(text_get("questionbuffersizewarning")))
		return 0

setting_render_shadows_point_buffer_size = argument0
