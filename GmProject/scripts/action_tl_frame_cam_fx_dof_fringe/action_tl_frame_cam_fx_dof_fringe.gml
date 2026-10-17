function action_tl_frame_cam_fx_dof_fringe(enabled)
{
	tl_value_set_start(action_tl_frame_cam_fx_dof_fringe, false)
	tl_value_set(e_value.CAM_FX_DOF_FRINGE, enabled, false)
	tl_value_set_done()
}
