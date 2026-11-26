function action_project_render_indirect_precision(value, add)
{
	action_project_render_preset_edit_locked()
	
	var precision = render_preset_edit.renderer[renderer_edit].indirect_precision;
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_indirect_precision, precision, precision * add + value / 100, true)
	else
		value *= 100
	
	render_preset_edit.renderer[renderer_edit].indirect_precision = precision * add + value / 100
	render_samples = -1
}
