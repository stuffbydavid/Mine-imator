/// action_project_render_aa_power(value, add)
/// @arg value
/// @arg add

function action_project_render_aa_power(val, add)
{
	action_project_render_preset_edit_locked()
	
	var settings = render_preset_edit.renderer[renderer_edit]
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_aa_power, settings.aa_power, settings.aa_power * add + val / 100, true)
	else
		val *= 100
	
	settings.aa_power = settings.aa_power * add + val / 100
}
