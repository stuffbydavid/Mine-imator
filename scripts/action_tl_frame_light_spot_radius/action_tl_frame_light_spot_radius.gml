/// action_tl_frame_light_spot_radius(value, add)
/// @arg value
/// @arg add

function action_tl_frame_light_spot_radius(val, add)
{
	tl_value_set_start(action_tl_frame_light_spot_radius, true)
	tl_value_set(e_value.LIGHT_SPOT_RADIUS, val, add)
	tl_value_set_done()
}
