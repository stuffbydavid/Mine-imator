/// action_tl_frame_ik_target(target)
/// @arg target

function action_tl_frame_ik_target(target)
{
	tl_value_set_start(action_tl_frame_ik_target, false)
	tl_value_set(e_value.IK_TARGET, target, false)
	tl_value_set_done()
}
