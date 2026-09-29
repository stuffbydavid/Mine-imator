function action_background_image_stretch(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_background_image_stretch, background_image_stretch, enabled, false)
	
	background_image_stretch = enabled
}
