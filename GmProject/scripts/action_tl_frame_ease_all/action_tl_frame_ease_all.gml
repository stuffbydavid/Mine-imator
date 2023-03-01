/// action_tl_frame_ease_all(value, add)
/// @arg value
/// @arg add

function action_tl_frame_ease_all(val, add)
{
	tl_value_set_start(action_tl_frame_ease_all, true)
	tl_value_set(e_value.EASE_IN_X, val[0], add)
	tl_value_set(e_value.EASE_IN_Y, val[1], add)
	tl_value_set(e_value.EASE_OUT_X, val[2], add)
	tl_value_set(e_value.EASE_OUT_Y, val[3], add)
	tl_value_set_done()
}
