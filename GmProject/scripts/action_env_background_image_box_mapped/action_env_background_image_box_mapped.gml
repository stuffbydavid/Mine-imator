function action_env_background_image_box_mapped(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_env_background_image_box_mapped, env_background_image_box_mapped, enabled, false)
	
	env_background_image_box_mapped = enabled
}
