/// action_setting_render_shadows_spot_buffer_size(size)
/// @arg size

function action_setting_render_shadows_spot_buffer_size(size)
{
	if (size >= 8192)
		if (!question(text_get("questionbuffersizewarning")))
			return 0
	
	setting_render_shadows_spot_buffer_size = size
	render_samples = -1
}
