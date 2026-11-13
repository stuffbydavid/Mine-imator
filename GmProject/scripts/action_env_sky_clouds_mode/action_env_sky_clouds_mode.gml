function action_env_sky_clouds_mode(mode)
{
	if (!history_undo && !history_redo)
		history_set_var(action_env_sky_clouds_mode, env_sky_clouds_mode, mode, false)
	
	env_sky_clouds_mode = mode
	env_sky_update_clouds()
}
