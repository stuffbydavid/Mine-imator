function action_background_fog_height(value, add)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single_type(e_tl_type.BACKGROUND))
		{
			tl_value_set_start(action_background_fog_height, true)
			tl_value_set(e_value.BG_FOG_HEIGHT, value, add)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_background_fog_height, background_fog_height, background_fog_height * add + value, true)
	}
	
	background_fog_height = background_fog_height * add + value
}
