/// action_tl_frame_alpha(value, add)
/// @arg value
/// @arg add

function action_tl_frame_alpha(val, add)
{
	tl_value_set_start(action_tl_frame_alpha, true)
	tl_value_set(e_value.ALPHA, val / 100, add)
	tl_value_set_done()
}
