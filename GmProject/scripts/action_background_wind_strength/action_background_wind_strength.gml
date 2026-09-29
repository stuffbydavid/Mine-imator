function action_background_wind_strength(value, add)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single_type(e_tl_type.BACKGROUND))
		{
			tl_value_set_start(action_background_wind_strength, true)
			tl_value_set(e_value.BG_WIND_STRENGTH, value, add)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_background_wind_strength, background_wind_strength, background_wind_strength * add + value, true)
	}
	
	background_wind_strength = background_wind_strength * add + value
}
