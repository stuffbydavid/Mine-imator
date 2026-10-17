function action_lib_shape_invert(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_shape_invert, temp_edit.shape_invert, enabled, false)
	
	with (temp_edit)
	{
		shape_invert = enabled
		temp_update_shape()
	}
	
	lib_preview.update = true
}
