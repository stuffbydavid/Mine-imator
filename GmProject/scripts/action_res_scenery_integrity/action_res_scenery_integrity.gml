function action_res_scenery_integrity(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_res_scenery_integrity, res_edit.scenery_integrity, res_edit.scenery_integrity * add + value / 100, true)
	else
		value *= 100
	
	with (res_edit)
		scenery_integrity = scenery_integrity * add + value / 100
	
	lib_preview.update = true
}
