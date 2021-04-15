/// action_background_sky_clouds_mode(mode)
/// @arg mode

var mode;

if (history_undo)
	mode = history_data.old_value
else if (history_redo)
	mode = history_data.new_value
else
{
	mode = argument0
	history_set_var(action_background_sky_clouds_mode, background_sky_clouds_mode, mode, false)
}

background_sky_clouds_mode = mode
background_sky_update_clouds()
