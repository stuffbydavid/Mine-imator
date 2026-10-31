function action_tl_frame_subsurface(value, add)
{
	tl_value_set_start(action_tl_frame_subsurface, true)
	tl_value_set(e_value.SUBSURFACE, value, add)
	tl_value_set_done()
}
