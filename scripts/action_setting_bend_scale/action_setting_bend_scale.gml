/// action_setting_bend_scale(value, add)
/// @arg value
/// @arg add

setting_bend_scale = setting_bend_scale * argument1 + argument0

with (obj_timeline)
{
	//tl_update_bend(true)
	update_matrix = true
}

tl_update_matrix()
