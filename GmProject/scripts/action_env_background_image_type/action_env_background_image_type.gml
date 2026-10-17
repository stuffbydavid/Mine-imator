function action_env_background_image_type(type)
{
	if (!history_undo && !history_redo)
		history_set_var(action_env_background_image_type, env_background_image_type, type, false)
	
	env_background_image_type = type
}
