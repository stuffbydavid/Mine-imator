function action_project_render_dof_quality(value, add)
{
	action_project_render_preset_edit_locked()
	
	var quality, nextquality;
	quality = render_preset_edit.renderer[renderer_edit].dof_quality
	nextquality = clamp(round(quality * add + value), 8, 64)
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_dof_quality, quality, nextquality, true)
	
	render_preset_edit.renderer[renderer_edit].dof_quality = nextquality
	project_render_dof_quality = nextquality
	render_samples = -1
}
