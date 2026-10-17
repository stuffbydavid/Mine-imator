function action_project_render_shadows_smoother_blur(enabled)
{
	action_project_render_preset_edit_locked()

	var settings = render_preset_edit.renderer[renderer_edit];

	if (!history_undo && !history_redo)
		history_set_var(action_project_render_shadows_smoother_blur, settings.shadows_smoother_blur, enabled, true)

	settings.shadows_smoother_blur = enabled
	project_render_shadows_smoother_blur = enabled
	render_samples = -1
}
