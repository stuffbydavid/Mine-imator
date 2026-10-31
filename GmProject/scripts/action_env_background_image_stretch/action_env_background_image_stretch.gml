function action_env_background_image_stretch(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_env_background_image_stretch, env_background_image_stretch, enabled, false)
	
	env_background_image_stretch = enabled
}
