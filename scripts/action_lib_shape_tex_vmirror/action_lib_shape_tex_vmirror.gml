/// action_lib_shape_tex_vmirror(vmirror)
/// @arg vmirror

function action_lib_shape_tex_vmirror(vmirror)
{
	if (!history_undo && !history_redo)
		history_set_var(action_lib_shape_tex_vmirror, temp_edit.shape_tex_vmirror, vmirror, false)
	
	with (temp_edit)
	{
		shape_tex_vmirror = vmirror
		temp_update_shape()
	}
	
	lib_preview.update = true
}
