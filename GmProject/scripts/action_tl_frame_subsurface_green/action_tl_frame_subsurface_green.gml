/// action_tl_frame_subsurface_green(value, add)
/// @arg value
/// @arg add

function action_tl_frame_subsurface_green(val, add)
{
	tl_value_set_start(action_tl_frame_subsurface_green, true)
	tl_value_set(e_value.SUBSURFACE_RADIUS_GREEN, val / 100, add)
	tl_value_set_done()
}