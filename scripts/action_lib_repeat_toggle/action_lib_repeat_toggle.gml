/// action_lib_repeat_toggle(repeat)
/// @arg repeat

var rep;

if (history_undo)
	rep = history_data.oldval
else if (history_redo)
	rep = history_data.newval
else
{
	rep = argument0
	history_set_var(action_lib_repeat_toggle, temp_edit.repeat_toggle, rep, false)
}

with (temp_edit)
{
	repeat_toggle = rep
	temp_update_block()
	temp_update_rot_point()
}

lib_preview.update = true
