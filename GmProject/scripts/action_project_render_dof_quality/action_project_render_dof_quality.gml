/// action_project_render_dof_quality(value, add)
/// @arg value
/// @arg add

function action_project_render_dof_quality(val, add)
{
	action_project_render_preset_edit_locked()
	var quality = render_preset_edit.renderer[renderer_edit].dof_quality
	var nextquality = clamp(round(quality * add + val), 8, 64)
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_dof_quality, quality, nextquality, true)
	render_preset_edit.renderer[renderer_edit].dof_quality = nextquality
	project_render_dof_quality = nextquality
	render_samples = -1
}
