function action_res_scenery_randomize(value)
{
	if (!history_undo && !history_redo)
		history_set_var(action_res_scenery_randomize, res_edit.scenery_randomize, value, true)
	
	with (res_edit)
	{
		res_load(true)
		scenery_randomize = value
	}
	
	lib_preview.update = true
}
