/// action_background_image_stretch(stretch)
/// @arg stretch

var stretch;

if (history_undo)
    stretch = history_data.oldval
else if (history_redo)
    stretch = history_data.newval
else
{
    stretch = argument0
    history_set_var(action_background_image_stretch, background_image_stretch, stretch, false)
}

background_image_stretch = stretch
