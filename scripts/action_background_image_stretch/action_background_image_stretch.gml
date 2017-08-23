/// action_background_image_stretch(stretch)
/// @arg stretch

var stretch;

if (history_undo)
	stretch = history_data.old_value
else if (history_redo)
	stretch = history_data.new_value
else
{
	stretch = argument0
	history_set_var(action_background_image_stretch, background_image_stretch, stretch, false)
}

background_image_stretch = stretch
