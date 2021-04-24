/// action_lib_shape_tex_hrepeat(value, add)
/// @arg value
/// @arg add

function action_lib_shape_tex_hrepeat(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_shape_tex_hrepeat, temp_edit.shape_tex_hrepeat, temp_edit.shape_tex_hrepeat * add + val, true)
	
	with (temp_edit)
	{
		shape_tex_hrepeat = shape_tex_hrepeat * add + val
		temp_update_shape()
	}
	
	lib_preview.update = true
}
