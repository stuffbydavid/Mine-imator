function action_tl_frame_cam_fx_dof_blur_size(value, add)
{
	tl_value_set_start(action_tl_frame_cam_fx_dof_blur_size, true)
	tl_value_set(e_value.CAM_FX_DOF_BLUR_SIZE, value / 100, add)
	tl_value_set_done()
}
