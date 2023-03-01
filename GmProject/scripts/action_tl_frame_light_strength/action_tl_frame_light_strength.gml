/// action_tl_frame_light_strength(value, add)
/// @arg value
/// @arg add

function action_tl_frame_light_strength(val, add)
{
	tl_value_set_start(action_tl_frame_light_strength, true)
	tl_value_set(e_value.LIGHT_STRENGTH, val / 100, add)
	tl_value_set_done()
}
