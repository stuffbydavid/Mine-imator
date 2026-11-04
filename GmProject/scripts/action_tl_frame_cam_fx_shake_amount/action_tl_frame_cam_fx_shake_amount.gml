function action_tl_frame_cam_fx_shake_amount(value, add)
{
	tl_value_set_start(action_tl_frame_cam_fx_shake_amount, true)
	for (var i = e_value.CAM_FX_SHAKE_STRENGTH_X; i <= e_value.CAM_FX_SHAKE_SPEED_Z; i++)
		tl_value_set(i, value / 100, add)
	tl_value_set_done()
}
