/// action_project_render_ssao(enable)
/// @arg enable

function action_project_render_ssao(enable)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_ssao, project_render_ssao, enable, 1)
	
	project_render_ssao = enable
}
