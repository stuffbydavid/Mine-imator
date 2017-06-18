/// action_background_fog_show(show)
/// @arg show

var show;

if (history_undo)
    show = history_data.oldval
else if (history_redo)
    show = history_data.newval
else
{
    show = argument0
    history_set_var(action_background_fog_show, background_fog_show, show, false)
}

background_fog_show = show
