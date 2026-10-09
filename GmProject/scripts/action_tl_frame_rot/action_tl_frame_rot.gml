function action_tl_frame_rot(value, add)
{
	tl_value_set_start(action_tl_frame_rot, true)
	tl_value_set(e_value.ROT_X + axis_edit, value, add)
	tl_value_set_done()
}
