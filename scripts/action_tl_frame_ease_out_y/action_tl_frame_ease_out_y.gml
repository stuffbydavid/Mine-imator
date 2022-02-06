/// action_tl_frame_ease_out_y(value, add)
/// @arg value
/// @arg add

function action_tl_frame_ease_out_y(val, add)
{
	tl_value_set_start(action_tl_frame_ease_out_y, true)
	tl_value_set(e_value.EASE_OUT_Y, val / 100, add)
	tl_value_set_done()
}
