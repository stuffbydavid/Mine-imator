/// action_background_sky_clouds_thickness(value, add)
/// @arg value
/// @arg add

function action_background_sky_clouds_thickness(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_background_sky_clouds_thickness, background_sky_clouds_thickness, background_sky_clouds_thickness * add + val, 1)
	
	background_sky_clouds_thickness = background_sky_clouds_thickness * add + val
	background_sky_update_clouds()
}
