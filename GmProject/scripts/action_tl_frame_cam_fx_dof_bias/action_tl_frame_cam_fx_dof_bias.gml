function action_tl_frame_cam_fx_dof_bias(value, add)
{
	tl_value_set_start(action_tl_frame_cam_fx_dof_bias, true)
	tl_value_set(e_value.CAM_FX_DOF_BIAS, value / 10, add)
	tl_value_set_done()
}
