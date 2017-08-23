/// action_lib_block_repeat(value, add)
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
	history_set_var(action_lib_block_repeat, temp_edit.block_repeat[axis_edit], temp_edit.block_repeat[axis_edit] * add + val, true)
}

with (temp_edit)
{
	block_repeat[axis_edit] = block_repeat[axis_edit] * add + val
	temp_update_block()
	temp_update_rot_point()
}

lib_preview.update = true
