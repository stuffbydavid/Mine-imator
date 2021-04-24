/// action_background_twilight(twilight)
/// @arg twilight

function action_background_twilight(twilight)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single(null, e_tl_type.BACKGROUND))
		{
			tl_value_set_start(action_background_twilight, true)
			tl_value_set(e_value.BG_TWILIGHT, twilight, false)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_background_twilight, background_twilight, twilight, false)
	}
	
	background_twilight = twilight
}
