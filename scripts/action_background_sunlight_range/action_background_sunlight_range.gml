/// action_background_sunlight_range(value, add)
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
    history_set_var(action_background_sunlight_range, background_sunlight_range, background_sunlight_range * add + val, true)
}

background_sunlight_range = background_sunlight_range * add + val
