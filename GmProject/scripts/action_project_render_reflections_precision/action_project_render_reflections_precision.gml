/// action_project_render_reflections_precision(value, add)
/// @arg value
/// @arg add

function action_project_render_reflections_precision(val, add)
{
	action_project_render_preset_edit_locked()
	
	var precision = render_preset_edit.realistic_reflections_precision;
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_reflections_precision, precision, precision * add + val / 100, true)
	else
		val *= 100
	
	render_preset_edit.realistic_reflections_precision = precision * add + val / 100
	render_samples = -1
}
