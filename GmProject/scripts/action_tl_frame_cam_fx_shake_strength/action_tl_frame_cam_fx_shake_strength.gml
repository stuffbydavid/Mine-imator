function action_tl_frame_cam_fx_shake_strength(value, add)
{
	tl_value_set_start(action_tl_frame_cam_fx_shake_strength, true)
	tl_value_set(e_value.CAM_FX_SHAKE_STRENGTH_X + axis_edit, value / 100, add)
	tl_value_set_done()
}
