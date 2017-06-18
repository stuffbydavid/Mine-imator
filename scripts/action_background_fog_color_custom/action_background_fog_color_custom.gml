/// action_background_fog_color_custom(custom)
/// @arg custom

var custom;

if (history_undo)
    custom = history_data.oldval
else if (history_redo)
    custom = history_data.newval
else
{
    custom = argument0
    history_set_var(action_background_fog_color_custom, background_fog_color_custom, custom, false)
}

background_fog_color_custom = custom
