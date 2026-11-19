function action_lib_shape_tex_mapped(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_shape_tex_mapped, temp_edit.shape_tex_mapped, enabled, false)
	
	with (temp_edit)
	{
		shape_tex_mapped = enabled
		temp_update_shape()
	}
	
	lib_preview.update = true
}
