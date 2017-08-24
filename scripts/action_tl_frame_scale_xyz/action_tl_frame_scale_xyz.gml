/// action_tl_frame_scale_xyz(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_scale_xyz, false)
tl_value_set(e_value.SCA_X, argument0[@ X], false)
tl_value_set(e_value.SCA_Y, argument0[@ Y], false)
tl_value_set(e_value.SCA_Z, argument0[@ Z], false)
tl_value_set_done()
