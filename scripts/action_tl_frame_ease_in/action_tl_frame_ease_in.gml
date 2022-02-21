/// action_tl_frame_ease_in(value, add)
/// @arg value
/// @arg add

function action_tl_frame_ease_in(val, add)
{
	tl_value_set_start(action_tl_frame_ease_in, true)
	tl_value_set(e_value.EASE_IN_X, val[0], add)
	tl_value_set(e_value.EASE_IN_Y, val[1], add)
	tl_value_set_done()
}
