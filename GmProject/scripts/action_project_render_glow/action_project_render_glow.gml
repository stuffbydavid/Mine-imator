/// action_project_render_glow(enable)
/// @arg enable

function action_project_render_glow(enable)
{
	action_project_render_preset_edit_locked()
	
	var settings = render_preset_edit.renderer[renderer_edit]
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_glow, settings.glow, enable, true)
	
	settings.glow = enable
}
