/// action_background_sky_clouds_offset(value, add)
/// @arg value
/// @arg add

function action_background_sky_clouds_offset(val, add)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single(null, e_tl_type.BACKGROUND))
		{
			tl_value_set_start(action_background_sky_clouds_offset, true)
			tl_value_set(e_value.BG_SKY_CLOUDS_OFFSET, val, add)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_background_sky_clouds_offset, background_sky_clouds_offset, background_sky_clouds_offset * add + val, 1)
	}
	
	background_sky_clouds_offset = background_sky_clouds_offset * add + val
}
