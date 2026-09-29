function action_background_sky_sun_angle(value, add)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single_type(e_tl_type.BACKGROUND))
		{
			tl_value_set_start(action_background_sky_sun_angle, true)
			tl_value_set(e_value.BG_SKY_SUN_ANGLE, value, add)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_background_sky_sun_angle, background_sky_sun_angle, background_sky_sun_angle * add + value, true)
	}
	
	background_sky_sun_angle = background_sky_sun_angle * add + value
}
