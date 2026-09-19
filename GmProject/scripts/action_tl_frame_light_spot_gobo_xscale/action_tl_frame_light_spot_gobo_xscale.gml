/// action_tl_frame_light_spot_gobo_xscale(value, add)
/// @arg value
/// @arg add

function action_tl_frame_light_spot_gobo_xscale(val, add)
{
	tl_value_set_start(action_tl_frame_light_spot_gobo_xscale, true)
	tl_value_set(e_value.LIGHT_GOBO_SCALE_X, val, add)
	tl_value_set_done()
}

/// action_tl_frame_light_spot_gobo_yscale(value, add)
/// @arg value
/// @arg add

function action_tl_frame_light_spot_gobo_yscale(val, add)
{
	tl_value_set_start(action_tl_frame_light_spot_gobo_yscale, true)
	tl_value_set(e_value.LIGHT_GOBO_SCALE_Y, val, add)
	tl_value_set_done()
}



