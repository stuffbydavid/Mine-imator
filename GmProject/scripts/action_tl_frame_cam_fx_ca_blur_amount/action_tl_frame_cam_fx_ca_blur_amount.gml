function action_tl_frame_cam_fx_ca_blur_amount(value, add)
{
	tl_value_set_start(action_tl_frame_cam_fx_ca_blur_amount, true)
	tl_value_set(e_value.CAM_FX_CA_BLUR_AMOUNT, value / 100, add)
	tl_value_set_done()
}
