/// action_lib_shape_tex_hoffset(value, add)
/// @arg value
/// @arg add

var val, add;
add = false

if (history_undo)
	val = history_data.oldval
else if (history_redo)
	val = history_data.newval
else
{
	val = argument0
	add = argument1
	history_set_var(action_lib_shape_tex_hoffset, temp_edit.shape_tex_hoffset, temp_edit.shape_tex_hoffset * add + val, true)
}

with (temp_edit)
{
	shape_tex_hoffset = shape_tex_hoffset * add + val
	temp_update_shape()
}
lib_preview.update = true
