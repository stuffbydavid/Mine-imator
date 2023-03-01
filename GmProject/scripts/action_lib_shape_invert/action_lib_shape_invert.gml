/// action_lib_shape_invert(invert)
/// @arg invert

function action_lib_shape_invert(invert)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_shape_invert, temp_edit.shape_invert, invert, false)
	
	with (temp_edit)
	{
		shape_invert = invert
		temp_update_shape()
	}
	lib_preview.update = true
}
