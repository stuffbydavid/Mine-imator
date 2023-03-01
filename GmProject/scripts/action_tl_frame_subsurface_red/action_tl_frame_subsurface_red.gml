/// action_tl_frame_subsurface_red(value, add)
/// @arg value
/// @arg add

function action_tl_frame_subsurface_red(val, add)
{
	tl_value_set_start(action_tl_frame_subsurface_red, true)
	tl_value_set(e_value.SUBSURFACE_RADIUS_RED, val / 100, add)
	tl_value_set_done()
}