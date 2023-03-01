/// action_project_render_gamma(val)
/// @arg val

function action_project_render_gamma(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_gamma, project_render_gamma, project_render_gamma * add + val, 1)
	
	project_render_gamma = project_render_gamma * add + val
	render_samples = -1
}
