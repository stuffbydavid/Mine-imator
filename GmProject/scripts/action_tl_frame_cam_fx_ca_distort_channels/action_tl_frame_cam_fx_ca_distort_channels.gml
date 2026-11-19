function action_tl_frame_cam_fx_ca_distort_channels(enabled)
{
	tl_value_set_start(action_tl_frame_cam_fx_ca_distort_channels, false)
	tl_value_set(e_value.CAM_FX_CA_DISTORT_CHANNELS, enabled, false)
	tl_value_set_done()
}
