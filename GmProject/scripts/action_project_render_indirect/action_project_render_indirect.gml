/// action_project_render_indirect(enable)
/// @arg enable

function action_project_render_indirect(enable)
{
	action_project_render_preset_edit_locked()
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_indirect, render_preset_edit.realistic_indirect, enable, true)
	
	render_preset_edit.realistic_indirect = enable
	render_samples = -1
}
