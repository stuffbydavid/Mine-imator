/// action_tl_frame_rot(value, add)
/// @arg value
/// @arg add

function action_tl_frame_rot(val, add)
{
	tl_value_set_start(action_tl_frame_rot, true)
	tl_value_set(e_value.ROT_X + axis_edit, val, add)
	tl_value_set_done()
}
