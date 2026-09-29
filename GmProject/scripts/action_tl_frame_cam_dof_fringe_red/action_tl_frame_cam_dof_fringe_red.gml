function action_tl_frame_cam_dof_fringe_red(value, add)
{
	tl_value_set_start(action_tl_frame_cam_dof_fringe_red, true)
	tl_value_set(e_value.CAM_DOF_FRINGE_RED, value / 100, add)
	tl_value_set_done()
}
