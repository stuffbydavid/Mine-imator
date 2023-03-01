/// action_background_fog_color_custom(custom)
/// @arg custom

function action_background_fog_color_custom(custom)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single(null, e_tl_type.BACKGROUND))
		{
			tl_value_set_start(action_background_fog_color_custom, true)
			tl_value_set(e_value.BG_FOG_CUSTOM_COLOR, custom, false)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_background_fog_color_custom, background_fog_color_custom, custom, false)
	}
	
	background_fog_color_custom = custom
}
