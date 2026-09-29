function action_res_scenery_integrity_invert(value)
{
	if (!history_undo && !history_redo)
		history_set_var(action_res_scenery_integrity_invert, res_edit.scenery_integrity_invert, value, true)
	
	with (res_edit)
	{
		res_load(true)
		scenery_integrity_invert = value
	}
	
	lib_preview.update = true
}
