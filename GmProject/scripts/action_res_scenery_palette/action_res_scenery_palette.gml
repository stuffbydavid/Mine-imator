function action_res_scenery_palette(value)
{
	if (!history_undo && !history_redo)
		history_set_var(action_res_scenery_palette, res_edit.scenery_palette, value, true)
	
	with (res_edit)
		scenery_palette = value
	
	lib_preview.update = true
}
