function action_tl_frame_cam_ca(enabled)
{
	tl_value_set_start(action_tl_frame_cam_ca, false)
	tl_value_set(e_value.CAM_CA, enabled, false)
	tl_value_set_done()
}
