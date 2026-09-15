/// action_background_brightness(value, add)
/// @arg value
/// @arg add

function action_background_brightness(val, add)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single(null, e_tl_type.BACKGROUND))
		{
			tl_value_set_start(action_background_brightness, true)
			tl_value_set(e_value.BG_BRIGHTNESS, val / 100, add)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_background_brightness, background_brightness, background_brightness * add + val / 100, true)
	}
	else
		val *= 100
	
	background_brightness = background_brightness * add + val / 100
}
