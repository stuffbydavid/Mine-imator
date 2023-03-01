/// action_res_scenery_randomize(value)
/// @arg value

function action_res_scenery_randomize(val)
{
	if (!history_undo && !history_redo)
		history_set_var(action_res_scenery_randomize, res_edit.scenery_randomize, val, true)
	
	with (res_edit)
	{
		res_load(true)
		scenery_randomize = val
	}
	
	lib_preview.update = true
}
