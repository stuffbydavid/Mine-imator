function action_tl_frame_ease_out(value, add)
{
	tl_value_set_start(action_tl_frame_ease_out, true)
	tl_value_set(e_value.EASE_OUT_X, value[0], add)
	tl_value_set(e_value.EASE_OUT_Y, value[1], add)
	tl_value_set_done()
}
