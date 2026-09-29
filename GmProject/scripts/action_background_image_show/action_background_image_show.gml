function action_background_image_show(enabled)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single_type(e_tl_type.BACKGROUND))
		{
			tl_value_set_start(action_background_image_show, true)
			tl_value_set(e_value.BG_IMAGE_SHOW, enabled, false)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_background_image_show, background_image_show, enabled, false)
	}
	
	background_image_show = enabled
}
