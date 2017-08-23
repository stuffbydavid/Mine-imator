/// action_background_night_color(color)
/// @arg color

if (history_undo)
	col = history_data.old_value
else if (history_redo)
	col = history_data.new_value
else
{
	col = argument0
	if (action_tl_select_single("background"))
	{
		tl_value_set_start(action_background_night_color, true)
		tl_value_set(BGNIGHTCOLOR, col, false)
		tl_value_set_done()
		return 0
	}
	history_set_var(action_background_night_color, background_night_color, col, true)
}

background_night_color = col
