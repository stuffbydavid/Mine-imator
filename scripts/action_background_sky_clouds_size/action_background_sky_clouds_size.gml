/// action_background_sky_clouds_size(value, add)
/// @arg value
/// @arg add

var val, add;
add = false

if (history_undo)
	val = history_data.old_value
else if (history_redo)
	val = history_data.new_value
else
{
	val = argument0
	add = argument1
	history_set_var(action_background_sky_clouds_size, background_sky_clouds_size, background_sky_clouds_size * add + val, true)
}

background_sky_clouds_size = background_sky_clouds_size * add + val
background_sky_update_clouds()
