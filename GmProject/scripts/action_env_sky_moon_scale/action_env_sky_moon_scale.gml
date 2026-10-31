function action_env_sky_moon_scale(value, add)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single_type(e_tl_type.ENVIRONMENT))
		{
			tl_value_set_start(action_env_sky_moon_scale, true)
			tl_value_set(e_value.ENV_SKY_MOON_SCALE, value / 100, add)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_env_sky_moon_scale, env_sky_moon_scale, env_sky_moon_scale * add + value / 100, true)
	}
	else
		value *= 100
	
	env_sky_moon_scale = env_sky_moon_scale * add + value / 100
}
