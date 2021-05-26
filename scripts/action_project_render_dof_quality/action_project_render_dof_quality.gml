/// action_project_render_dof_quality(value, add)
/// @arg value
/// @arg add

function action_project_render_dof_quality(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_dof_quality, project_render_dof_quality, project_render_dof_quality * add + val, 1)
	
	project_render_dof_quality = project_render_dof_quality * add + val
}
