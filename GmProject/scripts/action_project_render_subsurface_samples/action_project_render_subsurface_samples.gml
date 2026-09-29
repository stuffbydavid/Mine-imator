function action_project_render_subsurface_samples(value, add)
{
	action_project_render_preset_edit_locked()
	
	var samples = render_preset_edit.renderer[renderer_edit].subsurface_samples;
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_subsurface_samples, samples, samples * add + value, true)
	
	render_preset_edit.renderer[renderer_edit].subsurface_samples = samples * add + value
	render_samples = -1
}
