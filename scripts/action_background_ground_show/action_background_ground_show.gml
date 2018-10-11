/// action_background_ground_show(show)
/// @arg show

var show;

if (history_undo)
	show = history_data.old_value
else if (history_redo)
	show = history_data.new_value
else
{
	show = argument0
	if (action_tl_select_single(null, e_tl_type.BACKGROUND))
	{
		tl_value_set_start(action_background_ground_show, true)
		tl_value_set(e_value.BG_GROUND_SHOW, show, false)
		tl_value_set_done()
		return 0
	}
	history_set_var(action_background_ground_show, background_ground_show, show, false)
}

background_ground_show = show
