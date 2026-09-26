/// action_project_render_samples(value, add)
/// @arg value
/// @arg add

function action_project_render_samples(val, add)
{
	action_project_render_preset_edit_locked()

	var settings = render_preset_edit.renderer[renderer_edit]
	var samples = settings.samples
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_samples, samples, samples * add + val, true)
	
	settings.samples = samples * add + val
	
	if (settings.samples < samples)
		render_samples = -1
}
