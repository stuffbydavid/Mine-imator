function action_tl_frame_ik_angle_offset(value, add)
{
	tl_value_set_start(action_tl_frame_ik_angle_offset, true)
	tl_value_set(e_value.IK_ANGLE_OFFSET, value, add)
	tl_value_set_done()
}
