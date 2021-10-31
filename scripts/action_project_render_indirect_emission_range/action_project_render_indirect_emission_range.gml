/// action_project_render_indirect_range(value, add)
/// @arg value
/// @arg add

function action_project_render_indirect_range(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_indirect_range, project_render_indirect_range, project_render_indirect_range * add + val, 1)
	
	project_render_indirect_range = project_render_indirect_range * add + val
	render_samples = -1
}
