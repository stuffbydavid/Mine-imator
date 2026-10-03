function action_env_grass_color(color)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single_type(e_tl_type.ENVIRONMENT))
		{
			tl_value_set_start(action_env_grass_color, true)
			tl_value_set(e_value.ENV_GRASS_COLOR, color, false)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_env_grass_color, env_grass_color, color, true)
	}
	
	env_grass_color = color
	
	with (obj_resource)
		res_update_colors()
	
	properties.library.preview.update = true
}
