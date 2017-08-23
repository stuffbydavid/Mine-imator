/// action_background_wind(wind)
/// @arg wind

var wind;

if (history_undo)
	wind = history_data.old_value
else if (history_redo)
	wind = history_data.new_value
else
{
	wind = argument0
	history_set_var(action_background_wind, background_wind, wind, false)
}

background_wind = wind
