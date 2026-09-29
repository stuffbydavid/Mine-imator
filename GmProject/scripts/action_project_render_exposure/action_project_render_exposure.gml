function action_project_render_exposure(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_exposure, project_render_exposure, project_render_exposure * add + value, true)
	
	project_render_exposure = project_render_exposure * add + value
	render_samples = -1
}
