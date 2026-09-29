function action_tl_frame_cam_dof_threshold(value, add)
{
	tl_value_set_start(action_tl_frame_cam_dof_threshold, true)
	tl_value_set(e_value.CAM_DOF_THRESHOLD, value / 100, add)
	tl_value_set_done()
}
