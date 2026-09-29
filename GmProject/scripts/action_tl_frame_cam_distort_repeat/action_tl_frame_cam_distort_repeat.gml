function action_tl_frame_cam_distort_repeat(enabled)
{
	tl_value_set_start(action_tl_frame_cam_distort_repeat, false)
	tl_value_set(e_value.CAM_DISTORT_REPEAT, enabled, false)
	tl_value_set_done()
}
