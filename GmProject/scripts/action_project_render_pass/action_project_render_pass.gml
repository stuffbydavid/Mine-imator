/// action_project_render_pass(pass)
/// @arg pass

function action_project_render_pass(pass)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_pass, project_render_pass, pass, 1)
	
	project_render_pass = pass
	render_samples = -1
}