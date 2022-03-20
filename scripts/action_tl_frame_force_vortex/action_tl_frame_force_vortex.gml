/// action_tl_frame_force_vortex(value, add)
/// @arg value
/// @arg add

function action_tl_frame_force_vortex(val, add)
{
	tl_value_set_start(action_tl_frame_force_vortex, true)
	tl_value_set(e_value.FORCE_VORTEX, val, add)
	tl_value_set_done()
}
