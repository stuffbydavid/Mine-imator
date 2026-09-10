/// action_project_render_aa(enable)
/// @arg enable

function action_project_render_aa(enable)
{
	action_project_render_preset_edit_locked()
	
	var settings = render_preset_edit.renderer[renderer_edit]
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_aa, settings.aa, enable, true)
	
	settings.aa = enable
}
