function action_background_sky_time(value, add)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single_type(e_tl_type.BACKGROUND))
		{
			tl_value_set_start(action_background_sky_time, true)
			tl_value_set(e_value.BG_SKY_TIME, value, add)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_background_sky_time, background_sky_time, background_sky_time * add + value, true)
	}
	
	background_sky_time = background_sky_time * add + value
}
