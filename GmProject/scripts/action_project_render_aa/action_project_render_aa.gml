/// action_project_render_aa(enable)
/// @arg enable

function action_project_render_aa(enable)
{
	action_project_render_preset_edit_locked()
	
	var aa = renderer_edit_standard ? render_preset_edit.standard_aa : render_preset_edit.realistic_aa;
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_aa, aa, enable, true)
	
	if (renderer_edit_standard)
		render_preset_edit.standard_aa = enable
	else
		render_preset_edit.realistic_aa = enable
}
