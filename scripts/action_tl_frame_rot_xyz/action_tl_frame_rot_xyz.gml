/// action_tl_frame_rot_xyz(point)
/// @arg point

tl_value_set_start(action_tl_frame_rot_xyz, false)
tl_value_set(e_value.ROT_X, argument0[@ X], false)
tl_value_set(e_value.ROT_Y, argument0[@ Y], false)
tl_value_set(e_value.ROT_Z, argument0[@ Z], false)
tl_value_set_done()
