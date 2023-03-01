/// action_project_render_indirect_precision(size)
/// @arg size

function action_project_render_indirect_precision(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_indirect_precision, project_render_indirect_precision, project_render_indirect_precision * add + val / 100, 1)
	else
		val *= 100
	
	project_render_indirect_precision = project_render_indirect_precision * add + val / 100
	render_samples = -1
}
