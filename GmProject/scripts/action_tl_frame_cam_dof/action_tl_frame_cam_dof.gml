function action_tl_frame_cam_dof(enabled)
{
	tl_value_set_start(action_tl_frame_cam_dof, false)
	tl_value_set(e_value.CAM_DOF, enabled, false)
	tl_value_set_done()
}
