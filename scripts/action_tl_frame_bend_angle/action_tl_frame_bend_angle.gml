/// action_tl_frame_bend_angle(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_bend_angle, true)
tl_value_set(e_value.BEND_ANGLE_X + axis_edit, argument0, argument1)
tl_value_set_done()
