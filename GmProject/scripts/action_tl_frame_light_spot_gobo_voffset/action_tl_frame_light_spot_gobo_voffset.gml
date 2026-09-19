/// action_tl_frame_light_spot_gobo_voffset(value, add)
/// @arg value
/// @arg add

function action_tl_frame_light_spot_gobo_voffset(val, add)
{
	tl_value_set_start(action_tl_frame_light_spot_gobo_voffset, true)
	tl_value_set(e_value.LIGHT_SPOT_GOBO_V_OFFSET, val, add)
	tl_value_set_done()
}
