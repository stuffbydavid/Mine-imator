/// action_background_sky_rotation(value, add)
/// @arg value
/// @arg add

function action_background_sky_rotation(val, add)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single(null, e_tl_type.BACKGROUND))
		{
			tl_value_set_start(action_background_sky_rotation, true)
			tl_value_set(e_value.BG_SKY_ROTATION, val, add)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_background_sky_rotation, background_sky_rotation, background_sky_rotation * add + val, true)
	}
	
	background_sky_rotation = background_sky_rotation * add + val
}
