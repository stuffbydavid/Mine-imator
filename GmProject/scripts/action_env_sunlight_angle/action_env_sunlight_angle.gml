function action_env_sunlight_angle(value, add)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single_type(e_tl_type.ENVIRONMENT))
		{
			tl_value_set_start(action_env_sunlight_angle, true)
			tl_value_set(e_value.ENV_SUNLIGHT_ANGLE, value, add)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_env_sunlight_angle, env_sunlight_angle, env_sunlight_angle * add + value, true)
	}
	
	env_sunlight_angle = env_sunlight_angle * add + value
}
