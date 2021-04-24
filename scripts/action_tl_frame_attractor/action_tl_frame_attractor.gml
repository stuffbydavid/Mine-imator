/// action_tl_frame_attractor(attractor)
/// @arg attractor

function action_tl_frame_attractor(attractor)
{
	tl_value_set_start(action_tl_frame_attractor, false)
	tl_value_set(e_value.ATTRACTOR, attractor, false)
	tl_value_set_done()
}
