/// action_tl_frame_light_spot_sharpness(value, add)
/// @arg value
/// @arg add

function action_tl_frame_light_spot_sharpness(val, add)
{
	tl_value_set_start(action_tl_frame_light_spot_sharpness, true)
	tl_value_set(e_value.LIGHT_SPOT_SHARPNESS, val / 100, add)
	tl_value_set_done()
}
