/// action_background_sky_clouds_color(color)
/// @arg color

var col;

if (history_undo)
	col = history_data.oldval
else if (history_redo)
	col = history_data.newval
else
{
	col = argument0
	if (action_tl_select_single("background"))
	{
		tl_value_set_start(action_background_sky_clouds_color, true)
		tl_value_set(BGSKYCLOUDSCOLOR, col, false)
		tl_value_set_done()
		return 0
	}
	history_set_var(action_background_sky_clouds_color, background_sky_clouds_color, col, true)
}

background_sky_clouds_color = col
