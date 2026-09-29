function action_tl_frame_cam_distort(enabled)
{
	tl_value_set_start(action_tl_frame_cam_distort, false)
	tl_value_set(e_value.CAM_DISTORT, enabled, false)
	tl_value_set_done()
}
