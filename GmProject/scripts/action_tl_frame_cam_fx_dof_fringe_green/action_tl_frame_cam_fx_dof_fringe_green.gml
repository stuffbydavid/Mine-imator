function action_tl_frame_cam_fx_dof_fringe_green(value, add)
{
	tl_value_set_start(action_tl_frame_cam_fx_dof_fringe_green, true)
	tl_value_set(e_value.CAM_FX_DOF_FRINGE_GREEN, value / 100, add)
	tl_value_set_done()
}
