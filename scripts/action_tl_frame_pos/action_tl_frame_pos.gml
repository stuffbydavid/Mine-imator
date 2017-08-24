/// action_tl_frame_pos(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_pos, true)
tl_value_set(e_value.POS_X + axis_edit, argument0, argument1)
tl_value_set_done()
