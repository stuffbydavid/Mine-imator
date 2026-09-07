/// action_project_render_glow(enable)
/// @arg enable

function action_project_render_glow(enable)
{
	action_project_render_preset_edit_locked()
	
	var glow = renderer_edit_standard ? render_preset_edit.standard_glow : render_preset_edit.realistic_glow;
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_glow, glow, enable, true)
	
	if (renderer_edit_standard)
		render_preset_edit.standard_glow = enable
	else
		render_preset_edit.realistic_glow = enable
}
