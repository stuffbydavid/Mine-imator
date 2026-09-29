function action_background_sky_clouds_size_xy(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_background_sky_clouds_size_xy, background_sky_clouds_size_xy, background_sky_clouds_size_xy * add + value, true)
	
	background_sky_clouds_size_xy = background_sky_clouds_size_xy * add + value
	background_sky_update_clouds()
}
