/// action_project_render_indirect_quality(size)
/// @arg size

function action_project_render_indirect_quality(size)
{
	if (size >= 2)
		if (!question(text_get("questionqualitywarning")))
			return 0
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_indirect_quality, project_render_indirect_quality, size, 1)
	
	project_render_indirect_quality = size
	render_samples = -1
}
