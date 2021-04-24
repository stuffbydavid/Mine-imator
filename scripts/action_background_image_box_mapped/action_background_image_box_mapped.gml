/// action_background_image_box_mapped(mapped)
/// @arg mapped

function action_background_image_box_mapped(mapped)
{
	if (!history_undo && !history_redo)
		history_set_var(action_background_image_box_mapped, background_image_box_mapped, mapped, false)
	
	background_image_box_mapped = mapped
}
