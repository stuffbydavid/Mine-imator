function action_tl_frame_ease_all(value, add)
{
	tl_value_set_start(action_tl_frame_ease_all, true)
	tl_value_set(e_value.EASE_IN_X, value[0], add)
	tl_value_set(e_value.EASE_IN_Y, value[1], add)
	tl_value_set(e_value.EASE_OUT_X, value[2], add)
	tl_value_set(e_value.EASE_OUT_Y, value[3], add)
	tl_value_set_done()
}
