function action_background_sky_moon_scale(value, add)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single_type(e_tl_type.BACKGROUND))
		{
			tl_value_set_start(action_background_sky_moon_scale, true)
			tl_value_set(e_value.BG_SKY_MOON_SCALE, value / 100, add)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_background_sky_moon_scale, background_sky_moon_scale, background_sky_moon_scale * add + value / 100, true)
	}
	else
		value *= 100
	
	background_sky_moon_scale = background_sky_moon_scale * add + value / 100
}
