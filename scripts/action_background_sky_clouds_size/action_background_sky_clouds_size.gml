/// action_background_sky_clouds_size(value, add)
/// @arg value
/// @arg add

function action_background_sky_clouds_size(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_background_sky_clouds_size, background_sky_clouds_size, background_sky_clouds_size * add + val, true)
	
	background_sky_clouds_size = background_sky_clouds_size * add + val
	background_sky_update_clouds()
}
