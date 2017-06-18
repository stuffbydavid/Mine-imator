/// action_tl_frame_pos_xyz(point)
/// @arg point

tl_value_set_start(action_tl_frame_pos_xyz, false)
tl_value_set(XPOS, argument0[X], false)
tl_value_set(YPOS, argument0[Y], false)
tl_value_set(ZPOS, argument0[Z], false)
tl_value_set_done()
