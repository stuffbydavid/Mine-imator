/// action_tl_frame_pos_xyz(point)
/// @arg point

tl_value_set_start(action_tl_frame_pos_xyz, false)
tl_value_set(e_value.POS_X, argument0[@ X], false)
tl_value_set(e_value.POS_Y, argument0[@ Y], false)
tl_value_set(e_value.POS_Z, argument0[@ Z], false)
tl_value_set_done()
