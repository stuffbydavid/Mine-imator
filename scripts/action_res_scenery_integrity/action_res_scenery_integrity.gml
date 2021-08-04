/// action_res_scenery_integrity(value, add)
/// @arg value
/// @arg add

function action_res_scenery_integrity(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_res_scenery_integrity, res_edit.scenery_integrity * 100, res_edit.scenery_integrity * add + val / 100, true)
	
	with (res_edit)
		scenery_integrity = scenery_integrity * add + val / 100
	
	lib_preview.update = true
}
