function action_tl_frame_force(value, add)
{
	tl_value_set_start(action_tl_frame_force, true)
	tl_value_set(e_value.FORCE, value, add)
	tl_value_set_done()
}
