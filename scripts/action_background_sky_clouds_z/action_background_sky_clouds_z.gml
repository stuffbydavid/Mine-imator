/// action_background_sky_clouds_z(value, add)
/// @arg value
/// @arg add

var val, add;
add = false

if (history_undo)
	val = history_data.oldval
else if (history_redo)
	val = history_data.newval
else
{
	val = argument0
	add = argument1
	history_set_var(action_background_sky_clouds_z, background_sky_clouds_z, background_sky_clouds_z * add + val, true)
}

background_sky_clouds_z = background_sky_clouds_z * add + val
