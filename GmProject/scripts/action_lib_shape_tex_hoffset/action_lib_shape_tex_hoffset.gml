/// action_lib_shape_tex_hoffset(value, add)
/// @arg value
/// @arg add

function action_lib_shape_tex_hoffset(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_shape_tex_hoffset, temp_edit.shape_tex_hoffset, temp_edit.shape_tex_hoffset * add + val, true)
	
	with (temp_edit)
	{
		shape_tex_hoffset = shape_tex_hoffset * add + val
		temp_update_shape()
	}
	
	lib_preview.update = true
}
