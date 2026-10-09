function action_lib_shape_closed(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_shape_closed, temp_edit.shape_closed, enabled, false)
	
	with (temp_edit)
	{
		shape_closed = enabled
		temp_update_shape()
	}
	
	lib_preview.update = true
}
