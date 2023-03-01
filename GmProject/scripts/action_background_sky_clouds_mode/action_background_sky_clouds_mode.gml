/// action_background_sky_clouds_mode(mode)
/// @arg mode

function action_background_sky_clouds_mode(mode)
{
	if (!history_undo && !history_redo)
		history_set_var(action_background_sky_clouds_mode, background_sky_clouds_mode, mode, false)
	
	background_sky_clouds_mode = mode
	background_sky_update_clouds()
}
