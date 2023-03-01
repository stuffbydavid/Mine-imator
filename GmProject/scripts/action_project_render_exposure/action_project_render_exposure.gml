/// action_project_render_exposure(val)
/// @arg val

function action_project_render_exposure(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_exposure, project_render_exposure, project_render_exposure * add + val, 1)
	
	project_render_exposure = project_render_exposure * add + val
	render_samples = -1
}
