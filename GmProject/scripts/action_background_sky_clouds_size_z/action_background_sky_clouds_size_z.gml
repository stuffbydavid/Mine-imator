/// action_background_sky_clouds_size_z(value, add)
/// @arg value
/// @arg add

function action_background_sky_clouds_size_z(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_background_sky_clouds_size_z, background_sky_clouds_size_z, background_sky_clouds_size_z * add + val, 1)
	
	background_sky_clouds_size_z = background_sky_clouds_size_z * add + val
	background_sky_update_clouds()
}
