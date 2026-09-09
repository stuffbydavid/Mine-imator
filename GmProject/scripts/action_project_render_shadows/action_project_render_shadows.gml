/// action_project_render_shadows(enable)
/// @arg enable

function action_project_render_shadows(enable)
{
	action_project_render_preset_edit_locked()
	
	var settings = render_preset_edit.renderer[renderer_edit]
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_shadows, settings.shadows, enable, true)
	
	settings.shadows = enable
	render_samples = -1
}
