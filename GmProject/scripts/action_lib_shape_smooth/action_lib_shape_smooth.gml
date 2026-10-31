function action_lib_shape_smooth(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_shape_smooth, temp_edit.shape_smooth, enabled, false)
	
	with (temp_edit)
	{
		shape_smooth = enabled
		temp_update_shape()
	}
	
	lib_preview.update = true
}
