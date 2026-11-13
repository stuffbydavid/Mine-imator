function action_lib_shape_tex_voffset(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_shape_tex_voffset, temp_edit.shape_tex_voffset, temp_edit.shape_tex_voffset * add + value, true)
	
	with (temp_edit)
	{
		shape_tex_voffset = shape_tex_voffset * add + value
		temp_update_shape()
	}
	
	lib_preview.update = true
}
