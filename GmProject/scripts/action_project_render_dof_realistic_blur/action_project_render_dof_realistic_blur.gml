/// action_project_render_dof_realistic_blur(enable)
/// @arg enable

function action_project_render_dof_realistic_blur(enable)
{
	action_project_render_preset_edit_locked()
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_dof_realistic_blur, render_preset_edit.renderer[renderer_edit].dof_realistic_blur, enable, true)
	render_preset_edit.renderer[renderer_edit].dof_realistic_blur = enable
	project_render_dof_realistic_blur = enable
	render_samples = -1
}
