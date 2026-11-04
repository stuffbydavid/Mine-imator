function action_tl_frame_cam_fx_ca_green_offset(value, add)
{
	tl_value_set_start(action_tl_frame_cam_fx_ca_green_offset, true)
	tl_value_set(e_value.CAM_FX_CA_GREEN_OFFSET, value / 100, add)
	tl_value_set_done()
}
