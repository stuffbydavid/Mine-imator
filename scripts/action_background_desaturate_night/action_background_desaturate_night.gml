/// action_background_desaturate_night(desaturate)
/// @arg desaturate

function action_background_desaturate_night(desaturate)
{
	if (!history_undo && !history_redo)
	{
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
}
