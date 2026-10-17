function action_tl_frame_cam_fx_blade_amount(value, add)
{
	tl_value_set_start(action_tl_frame_cam_fx_blade_amount, true)
	tl_value_set(e_value.CAM_FX_BLADE_AMOUNT, value, add)
	tl_value_set_done()
}
