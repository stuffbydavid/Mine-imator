/// action_res_scenery_palette(value)
/// @arg value

function action_res_scenery_palette(val)
{
	if (!history_undo && !history_redo)
		history_set_var(action_res_scenery_palette, res_edit.scenery_palette, val, true)
	
	with (res_edit)
		scenery_palette = val
	
	lib_preview.update = true
}
