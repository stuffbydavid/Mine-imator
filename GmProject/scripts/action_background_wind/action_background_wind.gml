function action_background_wind(enabled)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single_type(e_tl_type.BACKGROUND))
		{
			tl_value_set_start(action_background_wind, true)
			tl_value_set(e_value.BG_WIND, enabled, false)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_background_wind, background_wind, enabled, false)
	}
	
	background_wind = enabled
}
