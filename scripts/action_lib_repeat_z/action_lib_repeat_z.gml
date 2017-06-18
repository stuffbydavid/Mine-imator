/// action_lib_repeat_z(value, add)
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
	history_set_var(action_lib_repeat_z, temp_edit.repeat_z, temp_edit.repeat_z * add + val, true)
}

with (temp_edit)
{
	repeat_z = repeat_z * add + val
	temp_update_block()
	temp_update_rot_point()
}

lib_preview.update = true
