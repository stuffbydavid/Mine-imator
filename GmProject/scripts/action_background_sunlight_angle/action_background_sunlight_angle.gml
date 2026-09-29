function action_background_sunlight_angle(value, add)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single_type(e_tl_type.BACKGROUND))
		{
			tl_value_set_start(action_background_sunlight_angle, true)
			tl_value_set(e_value.BG_SUNLIGHT_ANGLE, value, add)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_background_sunlight_angle, background_sunlight_angle, background_sunlight_angle * add + value, true)
	}
	
	background_sunlight_angle = background_sunlight_angle * add + value
}
