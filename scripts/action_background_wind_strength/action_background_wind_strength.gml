/// action_background_wind_strength(value, add)
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
    if (action_tl_select_single("background"))
	{
        tl_value_set_start(action_background_wind_strength, true)
        tl_value_set(BGWINDSTRENGTH, val, add)
        tl_value_set_done()
        return 0
    }
    history_set_var(action_background_wind_strength, background_wind_strength, background_wind_strength * add + val, true)
}

background_wind_strength = background_wind_strength * add + val
