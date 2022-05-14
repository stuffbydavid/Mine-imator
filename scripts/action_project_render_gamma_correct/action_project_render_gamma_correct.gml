/// action_project_render_gamma_correct(enable)
/// @arg enable

function action_project_render_gamma_correct(enable)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_gamma_correct, project_render_gamma_correct, enable, 1)
	
	project_render_gamma_correct = enable
	render_samples = -1
}
