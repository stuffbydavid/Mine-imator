function action_env_ground_slot(index)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single_type(e_tl_type.ENVIRONMENT))
		{
			tl_value_set_start(action_env_ground_slot, true)
			tl_value_set(e_value.ENV_GROUND_SLOT, index, false)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_env_ground_slot, env_ground_slot, index, true)
	}
	
	env_ground_slot = index
	
	env_ground_update_texture()
	env_ground_update_texture_normal()
	env_ground_update_texture_material()
}
