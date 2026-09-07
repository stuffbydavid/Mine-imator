/// action_project_render_ssao(enable)
/// @arg enable

function action_project_render_ssao(enable)
{
	action_project_render_preset_edit_locked()
	
	var ssao = renderer_edit_standard ? render_preset_edit.standard_ssao : render_preset_edit.realistic_ssao;
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_ssao, ssao, enable, true)
	
	if (renderer_edit_standard)
		render_preset_edit.standard_ssao = enable
	else
		render_preset_edit.realistic_ssao = enable
}
