function action_lib_shape_tex_vmirror(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_shape_tex_vmirror, temp_edit.shape_tex_vmirror, enabled, false)
	
	with (temp_edit)
	{
		shape_tex_vmirror = enabled
		temp_update_shape()
	}
	
	lib_preview.update = true
}
