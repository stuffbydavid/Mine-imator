function action_env_background_image_rotation(value, add)
{
	if (!history_undo && !history_redo)
	{
		if (action_tl_select_single_type(e_tl_type.ENVIRONMENT))
		{
			tl_value_set_start(action_env_background_image_rotation, true)
			tl_value_set(e_value.ENV_IMAGE_ROTATION, value, add)
			tl_value_set_done()
			return 0
		}
		
		history_set_var(action_env_background_image_rotation, env_background_image_rotation, env_background_image_rotation * add + value, true)
	}
	
	env_background_image_rotation = env_background_image_rotation * add + value
}
