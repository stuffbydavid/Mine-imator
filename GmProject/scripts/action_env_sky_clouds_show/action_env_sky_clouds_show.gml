function action_env_sky_clouds_show(enabled)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single_type(e_tl_type.ENVIRONMENT))
		{
			tl_value_set_start(action_env_sky_clouds_show, true)
			tl_value_set(e_value.ENV_SKY_CLOUDS_SHOW, enabled, false)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_env_sky_clouds_show, env_sky_clouds_show, enabled, false)
	}
	
	env_sky_clouds_show = enabled
}
