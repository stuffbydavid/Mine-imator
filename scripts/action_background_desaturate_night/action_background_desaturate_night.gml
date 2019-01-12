/// action_background_desaturate_night(desaturate)
/// @arg desaturate

var desaturate;

if (history_undo)
	desaturate = history_data.old_value
else if (history_redo)
	desaturate = history_data.new_value
else
{
	desaturate = argument0
	if (action_tl_select_single(null, e_tl_type.BACKGROUND))
	{
		tl_value_set_start(action_background_desaturate_night, true)
		tl_value_set(e_value.BG_DESATURATE_NIGHT, desaturate, false)
		tl_value_set_done()
		return 0
	}
	history_set_var(action_background_desaturate_night, background_desaturate_night, desaturate, false)
}
	
background_desaturate_night = desaturate
