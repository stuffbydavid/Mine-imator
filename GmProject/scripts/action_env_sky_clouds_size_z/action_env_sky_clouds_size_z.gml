function action_env_sky_clouds_size_z(value, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_env_sky_clouds_size_z, env_sky_clouds_size_z, env_sky_clouds_size_z * add + value, true)
	
	env_sky_clouds_size_z = env_sky_clouds_size_z * add + value
	env_sky_update_clouds()
}
