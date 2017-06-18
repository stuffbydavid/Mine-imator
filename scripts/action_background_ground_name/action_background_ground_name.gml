/// action_background_ground_name(name)
/// @arg name

var name;

if (history_undo)
    name = history_data.oldval
else if (history_redo)
    name = history_data.newval
else
{
    name = argument0
    history_set_var(action_background_ground_name, background_ground_name, name, false)
}

background_ground_name = name
background_ground_update_texture()
