/// action_background_sunlight_follow(follow)
/// @arg follow

function action_background_sunlight_follow(follow)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single(null, e_tl_type.BACKGROUND))
		{
			tl_value_set_start(action_background_sunlight_follow, true)
			tl_value_set(e_value.BG_SUNLIGHT_FOLLOW, follow, false)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_background_sunlight_follow, background_sunlight_follow, follow, false)
	}
	
	background_sunlight_follow = follow
}
