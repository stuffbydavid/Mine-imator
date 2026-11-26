function action_project_render_shadows_transparent(enabled)
{
	action_project_render_preset_edit_locked()
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_shadows_transparent, render_preset_edit.renderer[renderer_edit].shadows_transparent, enabled, true)
	
	render_preset_edit.renderer[renderer_edit].shadows_transparent = enabled
	render_samples = -1
}
