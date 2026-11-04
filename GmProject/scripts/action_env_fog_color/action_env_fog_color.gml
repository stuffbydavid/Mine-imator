function action_env_fog_color(color)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single_type(e_tl_type.ENVIRONMENT))
		{
			tl_value_set_start(action_env_fog_color, true)
			tl_value_set(e_value.ENV_FOG_COLOR, color, false)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_env_fog_color, env_fog_color, color, true)
	}
	
	env_fog_color = color
}
