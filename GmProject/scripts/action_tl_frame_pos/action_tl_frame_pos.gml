/// action_tl_frame_pos(value, add)
/// @arg value
/// @arg add

function action_tl_frame_pos(val, add)
{
	tl_value_set_start(action_tl_frame_pos, true)
	tl_value_set(e_value.POS_X + axis_edit, val, add)
	tl_value_set_done()
}
