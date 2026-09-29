function action_background_sky_clouds_size_z(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_background_sky_clouds_size_z, background_sky_clouds_size_z, background_sky_clouds_size_z * add + value, true)
	
	background_sky_clouds_size_z = background_sky_clouds_size_z * add + value
	background_sky_update_clouds()
}
