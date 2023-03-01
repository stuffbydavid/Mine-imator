/// action_background_image_type(type)
/// @arg type

function action_background_image_type(type)
{
	if (!history_undo && !history_redo)
		history_set_var(action_background_image_type, background_image_type, type, false)
	
	background_image_type = type
}
