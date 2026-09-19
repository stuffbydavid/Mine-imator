/// action_tl_frame_light_spot_gobo_hoffset(value, add)
/// @arg value
/// @arg add

function action_tl_frame_light_spot_gobo_hoffset(val, add)
{
	tl_value_set_start(action_tl_frame_light_spot_gobo_hoffset, true)
	tl_value_set(e_value.LIGHT_SPOT_GOBO_H_OFFSET, val, add)
	tl_value_set_done()
}
