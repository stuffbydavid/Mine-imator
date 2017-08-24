/// action_tl_frame_scale_all(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_scale_all, true)
tl_value_set(e_value.SCA_X, argument0, argument1)
tl_value_set(e_value.SCA_Y, argument0, argument1)
tl_value_set(e_value.SCA_Z, argument0, argument1)
tl_value_set_done()
