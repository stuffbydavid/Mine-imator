/// action_lib_block_data(value, add)
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
	history_set_var(action_lib_block_data, temp_edit.block_data, temp_edit.block_data * add + val, true)
}

with (temp_edit)
{
	block_data = block_data * add + val
	temp_update_block()
	temp_update_display_name()
}

lib_preview.update = true
