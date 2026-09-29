function action_tl_frame_cam_grain(enabled)
{
	tl_value_set_start(action_tl_frame_cam_grain, false)
	tl_value_set(e_value.CAM_GRAIN, enabled, false)
	tl_value_set_done()
}
