/// action_tl_frame_rot(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_rot, true)
tl_value_set(XROT + axis_edit, argument0, argument1)
tl_value_set_done()
