/// action_project_render_shadows_point_buffer_size(size)
/// @arg size

function action_project_render_shadows_point_buffer_size(size)
{
	if (size >= 4096)
		if (!question(text_get("questionbuffersizewarning")))
			return 0
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_shadows_point_buffer_size, project_render_shadows_point_buffer_size, size, 1)
	
	project_render_shadows_point_buffer_size = size
	render_samples = -1
}
