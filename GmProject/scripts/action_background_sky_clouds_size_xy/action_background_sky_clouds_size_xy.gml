/// action_background_sky_clouds_size_xy(value, add)
/// @arg value
/// @arg add

function action_background_sky_clouds_size_xy(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_background_sky_clouds_size_xy, background_sky_clouds_size_xy, background_sky_clouds_size_xy * add + val, true)
	
	background_sky_clouds_size_xy = background_sky_clouds_size_xy * add + val
	background_sky_update_clouds()
}
