/// action_tl_frame_bend_angle_xyz(bend)
/// @arg bend

tl_value_set_start(action_tl_frame_bend_angle_xyz, false)
tl_value_set(e_value.BEND_ANGLE_X, argument0[@ X], false)
tl_value_set(e_value.BEND_ANGLE_Y, argument0[@ Y], false)
tl_value_set(e_value.BEND_ANGLE_Z, argument0[@ Z], false)
tl_value_set_done()
