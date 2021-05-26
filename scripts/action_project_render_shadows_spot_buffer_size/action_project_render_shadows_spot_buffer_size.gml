/// action_project_render_shadows_spot_buffer_size(size)
/// @arg size

function action_project_render_shadows_spot_buffer_size(size)
{
	if (size >= 8192)
		if (!question(text_get("questionbuffersizewarning")))
			return 0
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_shadows_spot_buffer_size, project_render_shadows_spot_buffer_size, size, 1)
	
	project_render_shadows_spot_buffer_size = size
	render_samples = -1
}
