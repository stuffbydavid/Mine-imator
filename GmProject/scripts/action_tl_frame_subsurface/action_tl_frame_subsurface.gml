/// action_tl_frame_subsurface(value, add)
/// @arg value
/// @arg add

function action_tl_frame_subsurface(val, add)
{
	tl_value_set_start(action_tl_frame_subsurface, true)
	tl_value_set(e_value.SUBSURFACE, val, add)
	tl_value_set_done()
}
