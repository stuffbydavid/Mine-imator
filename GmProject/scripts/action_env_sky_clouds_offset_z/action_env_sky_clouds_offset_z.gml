function action_env_sky_clouds_offset_z(value, add)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single_type(e_tl_type.ENVIRONMENT))
		{
			tl_value_set_start(action_env_sky_clouds_offset_z, true)
			tl_value_set(e_value.ENV_SKY_CLOUDS_OFFSET_Z, value, add)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_env_sky_clouds_offset_z, env_sky_clouds_offset_z, env_sky_clouds_offset_z * add + value, true)
	}
	
	env_sky_clouds_offset_z = env_sky_clouds_offset_z * add + value
}
