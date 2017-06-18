/// action_background_wind(wind)
/// @arg wind

var wind;

if (history_undo)
    wind = history_data.oldval
else if (history_redo)
    wind = history_data.newval
else
{
    wind = argument0
    history_set_var(action_background_wind, background_wind, wind, false)
}

background_wind = wind
