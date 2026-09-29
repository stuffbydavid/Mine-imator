function action_tl_frame_cam_vignette(enabled)
{
	tl_value_set_start(action_tl_frame_cam_vignette, false)
	tl_value_set(e_value.CAM_VIGNETTE, enabled, false)
	tl_value_set_done()
}
