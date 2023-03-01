/// action_res_scenery_integrity_invert(value)
/// @arg value

function action_res_scenery_integrity_invert(val)
{
	if (!history_undo && !history_redo)
		history_set_var(action_res_scenery_integrity_invert, res_edit.scenery_integrity_invert, val, true)
	
	with (res_edit)
	{
		res_load(true)
		scenery_integrity_invert = val
	}
	
	lib_preview.update = true
}
