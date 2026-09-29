function action_background_sky_clouds_offset_z(value, add)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single_type(e_tl_type.BACKGROUND))
		{
			tl_value_set_start(action_background_sky_clouds_offset_z, true)
			tl_value_set(e_value.BG_SKY_CLOUDS_OFFSET_Z, value, add)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_background_sky_clouds_offset_z, background_sky_clouds_offset_z, background_sky_clouds_offset_z * add + value, true)
	}
	
	background_sky_clouds_offset_z = background_sky_clouds_offset_z * add + value
}
