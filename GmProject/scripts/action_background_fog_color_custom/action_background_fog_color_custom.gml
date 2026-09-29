function action_background_fog_color_custom(enabled)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single_type(e_tl_type.BACKGROUND))
		{
			tl_value_set_start(action_background_fog_color_custom, true)
			tl_value_set(e_value.BG_FOG_CUSTOM_COLOR, enabled, false)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_background_fog_color_custom, background_fog_color_custom, enabled, false)
	}
	
	background_fog_color_custom = enabled
}
