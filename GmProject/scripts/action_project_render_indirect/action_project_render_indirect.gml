/// action_project_render_indirect(enable)
/// @arg enable

function action_project_render_indirect(enable)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_indirect, project_render_indirect, enable, true)
	
	project_render_indirect = enable
	render_samples = -1
}
