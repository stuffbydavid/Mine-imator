function action_env_biome_color(color)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single_type(e_tl_type.ENVIRONMENT))
		{
			tl_value_set_start(action_env_biome_color, true)
			tl_value_set(e_value.ENV_GRASS_COLOR + biome_color_edit, color, false)
			tl_value_set_done()
			return 0
		}
		history_set_var(action_env_biome_color, env_color_list[biome_color_edit], color, true)
	}
	
	env_color_list[biome_color_edit] = color
	
	with (obj_resource)
		res_update_colors()
	
	properties.library.preview.update = true
}
