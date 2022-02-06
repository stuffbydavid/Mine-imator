/// action_tl_frame_ease_out_x(value, add)
/// @arg value
/// @arg add

function action_tl_frame_ease_out_x(val, add)
{
	tl_value_set_start(action_tl_frame_ease_out_x, true)
	tl_value_set(e_value.EASE_OUT_X, val / 100, add)
	tl_value_set_done()
}
