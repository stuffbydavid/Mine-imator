function action_project_render_shadows_jittered(enabled)
{
	action_project_render_preset_edit_locked()
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_shadows_jittered, render_preset_edit.renderer[renderer_edit].shadows_jittered, enabled, true)
	
	render_preset_edit.renderer[renderer_edit].shadows_jittered = enabled
	project_render_shadows_jittered = enabled
	render_samples = -1
}
