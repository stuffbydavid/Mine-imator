/// action_lib_shape_detail(value, add)
/// @arg value
/// @arg add

var val, add;
add = false

if (history_undo)
	val = history_data.old_value
else if (history_redo)
	val = history_data.new_value
else
{
	val = argument0
	add = argument1
	history_set_var(action_lib_shape_detail, temp_edit.shape_detail, temp_edit.shape_detail * add + val, true)
}

with (temp_edit)
{
	shape_detail = shape_detail * add + val
	temp_update_shape()
}
lib_preview.update = true
