function action_lib_shape_detail(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_shape_detail, temp_edit.shape_detail, temp_edit.shape_detail * add + value, true)
	
	with (temp_edit)
	{
		shape_detail = shape_detail * add + value
		temp_update_shape()
	}
	
	lib_preview.update = true
}
