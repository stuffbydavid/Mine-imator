/// action_setting_render_indirect_quality(size)
/// @arg size

function action_setting_render_indirect_quality(size)
{
	if (size >= 2)
		if (!question(text_get("questionqualitywarning")))
			return 0
	
	setting_render_indirect_quality = size
	render_samples = -1
}
