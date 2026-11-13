function action_project_render_ssao_radius(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_ssao_radius, project_render_ssao_radius, project_render_ssao_radius * add + value, true)
	
	project_render_ssao_radius = project_render_ssao_radius * add + value
}
