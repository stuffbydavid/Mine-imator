/// action_lib_block_repeat_enable(enable)
/// @arg enable

var rep;

if (history_undo)
	rep = history_data.old_value
else if (history_redo)
	rep = history_data.new_value
else
{
	rep = argument0
	history_set_var(action_lib_block_repeat_enable, temp_edit.block_repeat_enable, rep, false)
}

with (temp_edit)
{
	block_repeat_enable = rep
	temp_update_block()
	temp_update_rot_point()
}

lib_preview.update = true
