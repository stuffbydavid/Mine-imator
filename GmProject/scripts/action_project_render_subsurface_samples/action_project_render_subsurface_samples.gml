/// action_project_render_subsurface_samples(value, add)
/// @arg value
/// @arg add

function action_project_render_subsurface_samples(val, add)
{
	action_project_render_preset_edit_locked()
	
	var samples = render_preset_edit.realistic_subsurface_samples;
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_subsurface_samples, samples, samples * add + val, true)
	
	render_preset_edit.realistic_subsurface_samples = samples * add + val
	render_samples = -1
}
