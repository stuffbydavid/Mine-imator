function action_tl_frame_cam_fx_dof_blur_ratio(value, add)
{
	tl_value_set_start(action_tl_frame_cam_fx_dof_blur_ratio, true)
	tl_value_set(e_value.CAM_FX_DOF_BLUR_RATIO, value / 100, add)
	tl_value_set_done()
}
