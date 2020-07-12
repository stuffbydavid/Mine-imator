/// action_setting_render_indirect_quality(size)
/// @arg size

if (argument0 >= 2)
	if (!question(text_get("questionqualitywarning")))
		return 0

setting_render_indirect_quality = argument0

render_samples = -1
