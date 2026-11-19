function action_env_sky_clouds_size_xy(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_env_sky_clouds_size_xy, env_sky_clouds_size_xy, env_sky_clouds_size_xy * add + value, true)
	
	env_sky_clouds_size_xy = env_sky_clouds_size_xy * add + value
	env_sky_update_clouds()
}
