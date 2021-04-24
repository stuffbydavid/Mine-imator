/// action_lib_shape_detail(value, add)
/// @arg value
/// @arg add

function action_lib_shape_detail(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_shape_detail, temp_edit.shape_detail, temp_edit.shape_detail * add + val, true)
	
	with (temp_edit)
	{
		shape_detail = shape_detail * add + val
		temp_update_shape()
	}
	lib_preview.update = true
}
