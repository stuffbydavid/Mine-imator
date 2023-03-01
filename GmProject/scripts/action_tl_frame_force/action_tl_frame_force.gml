/// action_tl_frame_force(value, add)
/// @arg value
/// @arg add

function action_tl_frame_force(val, add)
{
	tl_value_set_start(action_tl_frame_force, true)
	tl_value_set(e_value.FORCE, val, add)
	tl_value_set_done()
}
