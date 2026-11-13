function action_tl_frame_cam_fx_clrcor_brightness(value, add)
{
	tl_value_set_start(action_tl_frame_cam_fx_clrcor_brightness, true)
	tl_value_set(e_value.CAM_FX_BRIGHTNESS, value / 100, add)
	tl_value_set_done()
}
