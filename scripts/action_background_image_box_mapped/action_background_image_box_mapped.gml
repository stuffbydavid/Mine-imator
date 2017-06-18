/// action_background_image_box_mapped(mapped)
/// @arg mapped

var mapped;

if (history_undo)
    mapped = history_data.oldval
else if (history_redo)
    mapped = history_data.newval
else
{
    mapped = argument0
    history_set_var(action_background_image_box_mapped, background_image_box_mapped, mapped, false)
}

background_image_box_mapped = mapped
