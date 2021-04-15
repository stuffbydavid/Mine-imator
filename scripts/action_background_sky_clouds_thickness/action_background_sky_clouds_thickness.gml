/// action_background_sky_clouds_thickness(value, add)
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
	history_set_var(action_background_sky_clouds_thickness, background_sky_clouds_thickness, background_sky_clouds_thickness * add + val, 1)
}
	
background_sky_clouds_thickness = background_sky_clouds_thickness * add + val
background_sky_update_clouds()
