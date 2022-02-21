/// action_tl_frame_ease_out(value, add)
/// @arg value
/// @arg add

function action_tl_frame_ease_out(val, add)
{
	tl_value_set_start(action_tl_frame_ease_out, true)
	tl_value_set(e_value.EASE_OUT_X, val[0], add)
	tl_value_set(e_value.EASE_OUT_Y, val[1], add)
	tl_value_set_done()
}
