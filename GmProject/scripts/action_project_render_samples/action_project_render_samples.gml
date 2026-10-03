function action_project_render_samples(value, add)
{
	action_project_render_preset_edit_locked()

	var settings, samples;
	settings = render_preset_edit.renderer[renderer_edit]
	samples = settings.samples
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_samples, samples, samples * add + value, true)
	
	settings.samples = samples * add + value
	
	if (settings.samples < samples)
		render_samples = -1
}
