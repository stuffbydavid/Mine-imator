/// action_project_render_distance(value, add)
/// @arg value
/// @arg add

function action_project_render_distance(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_distance, project_render_distance, project_render_distance * add + val, true)
		
	project_render_distance = project_render_distance * add + val
}
