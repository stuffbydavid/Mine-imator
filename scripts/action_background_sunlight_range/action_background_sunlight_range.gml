/// action_background_sunlight_range(value, add)
/// @arg value
/// @arg add

function action_background_sunlight_range(val, add)
{
	if (!history_undo && !history_redo)
	{
		val = argument0
		add = argument1
		if (action_tl_select_single(null, e_tl_type.BACKGROUND))
		{
			tl_value_set_start(action_background_sunlight_range, true)
			tl_value_set(e_value.BG_SUNLIGHT_RANGE, val, add)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_background_sunlight_range, background_sunlight_range, background_sunlight_range * add + val, true)
	}
	
	background_sunlight_range = background_sunlight_range * add + val
}
