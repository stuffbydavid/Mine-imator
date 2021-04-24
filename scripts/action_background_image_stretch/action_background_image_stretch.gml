/// action_background_image_stretch(stretch)
/// @arg stretch

function action_background_image_stretch(stretch)
{
	if (!history_undo && !history_redo)
		history_set_var(action_background_image_stretch, background_image_stretch, stretch, false)
	
	background_image_stretch = stretch
}
