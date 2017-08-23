/// action_background_fog_sky(show)
/// @arg show

var show;

if (history_undo)
	show = history_data.old_value
else if (history_redo)
	show = history_data.new_value
else
{
	show = argument0
	history_set_var(action_background_fog_sky, background_fog_sky, show, false)
}

background_fog_sky = show
