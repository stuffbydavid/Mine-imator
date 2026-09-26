/// action_background_sky_clouds_offset_y(value, add)
/// @arg value
/// @arg add

function action_background_sky_clouds_offset_y(val, add)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single(null, e_tl_type.BACKGROUND))
		{
			tl_value_set_start(action_background_sky_clouds_offset_y, true)
			tl_value_set(e_value.BG_SKY_CLOUDS_OFFSET_Y, val, add)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_background_sky_clouds_offset_y, background_sky_clouds_offset_y, background_sky_clouds_offset_y * add + val, 1)
	}
	
	background_sky_clouds_offset_y = background_sky_clouds_offset_y * add + val
}
