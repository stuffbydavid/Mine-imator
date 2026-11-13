function action_tl_frame_ease_in_x(value, add)
{
	tl_value_set_start(action_tl_frame_ease_in_x, true)
	tl_value_set(e_value.EASE_IN_X, value / 100, add)
	tl_value_set_done()
}
