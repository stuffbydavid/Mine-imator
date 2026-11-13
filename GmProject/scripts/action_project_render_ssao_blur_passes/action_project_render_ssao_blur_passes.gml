function action_project_render_ssao_blur_passes(value, add)
{
	action_project_render_preset_edit_locked()

	var oldpasses, passes;
	oldpasses = render_preset_edit.renderer[renderer_edit].ssao_blur_passes
	passes = clamp(round(oldpasses * add + value), 0, 8)
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_ssao_blur_passes, oldpasses, passes, true)
	
	render_preset_edit.renderer[renderer_edit].ssao_blur_passes = passes
	project_render_ssao_blur_passes = passes
}
