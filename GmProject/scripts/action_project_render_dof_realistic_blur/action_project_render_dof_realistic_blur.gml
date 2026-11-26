function action_project_render_dof_realistic_blur(enabled)
{
	action_project_render_preset_edit_locked()
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_dof_realistic_blur, render_preset_edit.renderer[renderer_edit].dof_realistic_blur, enabled, true)
	
	render_preset_edit.renderer[renderer_edit].dof_realistic_blur = enabled
	project_render_dof_realistic_blur = enabled
	render_samples = -1
}
