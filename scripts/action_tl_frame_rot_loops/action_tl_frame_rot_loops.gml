/// action_tl_frame_rot_loops(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_rot_loops, true)
tl_value_set(XROT + axis_edit, argument0 * 360 + mod_fix(tl_edit.value[XROT + axis_edit], 360)*!argument1, argument1)
tl_value_set_done()
