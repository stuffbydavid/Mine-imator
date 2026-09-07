/// action_project_render_glow_falloff(enable)
/// @arg enable

function action_project_render_glow_falloff(enable)
{
	action_project_render_preset_edit_locked()
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_glow_falloff, render_preset_edit.realistic_glow_falloff, enable, true)
	
	render_preset_edit.realistic_glow_falloff = enable
}
