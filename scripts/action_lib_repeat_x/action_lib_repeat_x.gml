/// action_lib_repeat_x(value, add)
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
    history_set_var(action_lib_repeat_x, temp_edit.repeat_x, temp_edit.repeat_x * add + val, true)
}

with (temp_edit)
{
    repeat_x = repeat_x * add + val
    temp_update_block()
    temp_update_rot_point()
}

lib_preview.update = true
