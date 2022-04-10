/// action_tl_frame_ik_target_angle(target)
/// @arg target

function action_tl_frame_ik_target_angle(target)
{
	tl_value_set_start(action_tl_frame_ik_target_angle, false)
	tl_value_set(e_value.IK_TARGET_ANGLE, target, false)
	tl_value_set_done()
}
