function action_background_image_box_mapped(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_background_image_box_mapped, background_image_box_mapped, enabled, false)
	
	background_image_box_mapped = enabled
}
