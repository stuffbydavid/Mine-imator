/// action_tl_frame_light_spot_gobo_hrepeat(value, add)
/// @arg value
/// @arg add

function action_tl_frame_light_spot_gobo_hrepeat(val, add)
{
	tl_value_set_start(action_tl_frame_light_spot_gobo_hrepeat, true)
	tl_value_set(e_value.LIGHT_SPOT_GOBO_H_REPEAT, val, add)
	tl_value_set_done()
}


