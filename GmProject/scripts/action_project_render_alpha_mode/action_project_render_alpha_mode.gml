/// action_project_render_alpha_mode(mode)
/// @arg mode

function action_project_render_alpha_mode(mode)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_alpha_mode, project_render_alpha_mode, mode, true)
	
	project_render_alpha_mode = mode
	render_samples = -1
}
