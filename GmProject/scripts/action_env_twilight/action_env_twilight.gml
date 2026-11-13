function action_env_twilight(enabled)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single_type(e_tl_type.ENVIRONMENT))
		{
			tl_value_set_start(action_env_twilight, true)
			tl_value_set(e_value.ENV_TWILIGHT, enabled, false)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_env_twilight, env_twilight, enabled, false)
	}
	
	env_twilight = enabled
}
