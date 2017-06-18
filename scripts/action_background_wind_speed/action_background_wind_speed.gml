/// action_background_wind_speed(value, add)
/// @arg value
/// @arg add

var val, add;
add = false

if (history_undo)
    val = history_data.oldval * 100
else if (history_redo)
    val = history_data.newval * 100
else
{
    val = argument0
    add = argument1
    if (action_tl_select_single("background"))
	{
        tl_value_set_start(action_background_wind_speed, true)
        tl_value_set(BGWINDSPEED, val / 100, add)
        tl_value_set_done()
        return 0
    }
    history_set_var(action_background_wind_speed, background_wind_speed, background_wind_speed * add + val / 100, true)
}

background_wind_speed = background_wind_speed * add + val / 100
