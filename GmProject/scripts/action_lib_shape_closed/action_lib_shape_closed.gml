/// action_lib_shape_closed(closed)
/// @arg closed

function action_lib_shape_closed(closed)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_shape_closed, temp_edit.shape_closed, closed, false)
	
	with (temp_edit)
	{
		shape_closed = closed
		temp_update_shape()
	}
	lib_preview.update = true
}
