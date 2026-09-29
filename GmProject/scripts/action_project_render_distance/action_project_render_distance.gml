function action_project_render_distance(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_distance, project_render_distance, project_render_distance * add + value, true)
		
	project_render_distance = project_render_distance * add + value
}
