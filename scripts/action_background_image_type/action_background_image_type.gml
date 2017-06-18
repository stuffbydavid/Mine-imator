/// action_background_image_type(type)
/// @arg type

var type;

if (history_undo)
	type = history_data.oldval
else if (history_redo)
	type = history_data.newval
else
{
	type = argument0
	history_set_var(action_background_image_type, background_image_type, type, false)
}

background_image_type = type
