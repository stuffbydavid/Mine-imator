function action_project_render_shadows(enabled)
{
	action_project_render_preset_edit_locked()
	
	var settings = render_preset_edit.renderer[renderer_edit];
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_shadows, settings.shadows, enabled, true)
	
	settings.shadows = enabled
	render_samples = -1
}
