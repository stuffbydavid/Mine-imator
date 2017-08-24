/// action_background_ambient_color(color)
/// @arg color

var col;

if (history_undo)
	col = history_data.old_value
else if (history_redo)
	col = history_data.new_value
else
{
	col = argument0
	if (action_tl_select_single("background"))
	{
		tl_value_set_start(action_background_ambient_color, true)
		tl_value_set(e_value.BG_AMBIENT_COLOR, col, false)
		tl_value_set_done()
		return 0
	}
	history_set_var(action_background_ambient_color, background_ambient_color, col, true)
}

background_ambient_color = col
