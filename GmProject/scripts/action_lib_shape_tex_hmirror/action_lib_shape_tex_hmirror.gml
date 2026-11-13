function action_lib_shape_tex_hmirror(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_shape_tex_hmirror, temp_edit.shape_tex_hmirror, enabled, false)
	
	with (temp_edit)
	{
		shape_tex_hmirror = enabled
		temp_update_shape()
	}
	
	lib_preview.update = true
}
