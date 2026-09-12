/// action_lib_shape_smooth(smooth)
/// @arg smooth

function action_lib_shape_smooth(smooth)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_shape_smooth, temp_edit.shape_smooth, smooth, false)
	
	with (temp_edit)
	{
		shape_smooth = smooth
		temp_update_shape()
	}
	lib_preview.update = true
}