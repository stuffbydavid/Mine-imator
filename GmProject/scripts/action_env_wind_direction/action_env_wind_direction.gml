function action_env_wind_direction(value, add)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single_type(e_tl_type.ENVIRONMENT))
		{
			tl_value_set_start(action_env_wind_direction, true)
			tl_value_set(e_value.ENV_WIND_DIRECTION, value, add)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_env_wind_direction, env_wind_direction, env_wind_direction * add + value, true)
	}
	
	env_wind_direction = env_wind_direction * add + value
}
