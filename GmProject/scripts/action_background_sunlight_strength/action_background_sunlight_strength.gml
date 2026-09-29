function action_background_sunlight_strength(value, add)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single_type(e_tl_type.BACKGROUND))
		{
			tl_value_set_start(action_background_sunlight_strength, true)
			tl_value_set(e_value.BG_SUNLIGHT_STRENGTH, value / 100, add)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_background_sunlight_strength, background_sunlight_strength, background_sunlight_strength * add + value / 100, true)
	}
	else
		value *= 100
	
	background_sunlight_strength = background_sunlight_strength * add + value / 100
}
