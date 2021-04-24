/// action_tl_frame_brightness(value, add)
/// @arg value
/// @arg add

function action_tl_frame_brightness(val, add)
{
	tl_value_set_start(action_tl_frame_brightness, true)
	tl_value_set(e_value.BRIGHTNESS, val / 100, add)
	tl_value_set_done()

}
