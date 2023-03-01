/// action_tl_frame_transition(name)
/// @arg name

function action_tl_frame_transition(name)
{
	tl_value_set_start(action_tl_frame_transition, false)
	tl_value_set(e_value.TRANSITION, name, false)
	tl_value_set_done()
}
