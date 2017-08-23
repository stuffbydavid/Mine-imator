/// action_lib_shape_tex_vmirror(vmirror)
/// @arg vmirror

var vmirror;

if (history_undo)
	vmirror = history_data.old_value
else if (history_redo)
	vmirror = history_data.new_value
else
{
	vmirror = argument0
	history_set_var(action_lib_shape_tex_vmirror, temp_edit.shape_tex_vmirror, vmirror, false)
}

with (temp_edit)
{
	shape_tex_vmirror = vmirror
	temp_update_shape()
}
lib_preview.update = true
