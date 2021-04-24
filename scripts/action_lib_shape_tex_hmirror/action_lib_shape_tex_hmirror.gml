/// action_lib_shape_tex_hmirror(hmirror)
/// @arg hmirror

function action_lib_shape_tex_hmirror(hmirror)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_shape_tex_hmirror, temp_edit.shape_tex_hmirror, hmirror, false)
	
	with (temp_edit)
	{
		shape_tex_hmirror = hmirror
		temp_update_shape()
	}
	
	lib_preview.update = true
}
