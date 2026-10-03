function action_tl_frame_alpha(value, add)
{
	tl_value_set_start(action_tl_frame_alpha, true)
	tl_value_set(e_value.ALPHA, value / 100, add)
	tl_value_set_done()
}
