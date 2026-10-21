function action_tl_frame_ease_in(value, add)
{
	tl_value_set_start(action_tl_frame_ease_in, true)
	tl_value_set(e_value.EASE_IN_X, value[0], add)
	tl_value_set(e_value.EASE_IN_Y, value[1], add)
	tl_value_set_done()
}
