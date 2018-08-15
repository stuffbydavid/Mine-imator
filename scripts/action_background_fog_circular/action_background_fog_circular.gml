/// action_background_fog_circular(circular)
/// @arg circular

var circular;

if (history_undo)
	circular = history_data.old_value
else if (history_redo)
	circular = history_data.new_value
else
{
	circular = argument0
	history_set_var(action_background_fog_circular, background_fog_circular, circular, false)
}

background_fog_circular = circular
