/// action_background_sunlight_strength(value, add)
/// @arg value
/// @arg add

function action_background_sunlight_strength(val, add)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single(null, e_tl_type.BACKGROUND))
		{
			tl_value_set_start(action_background_sunlight_strength, true)
			tl_value_set(e_value.BG_SUNLIGHT_STRENGTH, val / 100, add)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_background_sunlight_strength, background_sunlight_strength, background_sunlight_strength * add + val / 100, true)
	}
	else
		val *= 100
	
	background_sunlight_strength = background_sunlight_strength * add + val / 100
	
	// Temporary bugfix for floating point issue
	if (background_sunlight_strength = 0)
		background_sunlight_strength = 0
}
