/// action_setting_bend_pinch(value)
/// @arg value

setting_bend_pinch = argument0

// Force update timeline meshes
with (obj_timeline)
{
	bend_rot_last = vec3(0)
	tl_update_model_shape_bend()
}