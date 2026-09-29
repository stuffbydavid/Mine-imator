function action_background_wind_directional_speed(value, add)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single_type(e_tl_type.BACKGROUND))
		{
			tl_value_set_start(action_background_wind_directional_speed, true)
			tl_value_set(e_value.BG_WIND_DIRECTIONAL_SPEED, value / 100, add)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_background_wind_directional_speed, background_wind_directional_speed, background_wind_directional_speed * add + value / 100, true)
	}
	else
		value *= 100
	
	background_wind_directional_speed = background_wind_directional_speed * add + value / 100
}
