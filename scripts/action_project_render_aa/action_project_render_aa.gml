/// action_project_render_aa(enable)
/// @arg enable

function action_project_render_aa(enable)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_aa, project_render_aa, enable, true)
	
	project_render_aa = enable
}
