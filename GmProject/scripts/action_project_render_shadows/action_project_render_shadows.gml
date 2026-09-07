/// action_project_render_shadows(enable)
/// @arg enable

function action_project_render_shadows(enable)
{
	action_project_render_preset_edit_locked()
	
	var shadows = renderer_edit_standard ? render_preset_edit.standard_shadows : render_preset_edit.realistic_shadows;
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_shadows, shadows, enable, true)
	
	if (renderer_edit_standard)
		render_preset_edit.standard_shadows = enable
	else
		render_preset_edit.realistic_shadows = enable
	render_samples = -1
}
