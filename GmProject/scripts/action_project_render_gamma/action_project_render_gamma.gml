function action_project_render_gamma(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_gamma, project_render_gamma, project_render_gamma * add + value, true)
	
	project_render_gamma = project_render_gamma * add + value
	render_samples = -1
}
