/// action_lib_shape_tex_vrepeat(value, add)
/// @arg value
/// @arg add

function action_lib_shape_tex_vrepeat(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_shape_tex_vrepeat, temp_edit.shape_tex_vrepeat, temp_edit.shape_tex_vrepeat * add + val, true)
	
	with (temp_edit)
	{
		shape_tex_vrepeat = shape_tex_vrepeat * add + val
		temp_update_shape()
	}
	
	lib_preview.update = true
}
