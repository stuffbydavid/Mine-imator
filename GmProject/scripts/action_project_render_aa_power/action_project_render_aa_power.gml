/// action_project_render_aa_power(value, add)
/// @arg value
/// @arg add

function action_project_render_aa_power(val, add)
{
	action_project_render_preset_edit_locked()
	
	var aapower = renderer_edit_standard ? render_preset_edit.standard_aa_power : render_preset_edit.realistic_aa_power;
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_aa_power, aapower, aapower * add + val / 100, true)
	else
		val *= 100
	
	if (renderer_edit_standard)
		render_preset_edit.standard_aa_power = aapower * add + val / 100
	else
		render_preset_edit.realistic_aa_power = aapower * add + val / 100
}
