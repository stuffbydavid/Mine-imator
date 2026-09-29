function action_tl_frame_cam_bloom(enabled)
{
	tl_value_set_start(action_tl_frame_cam_bloom, false)
	tl_value_set(e_value.CAM_BLOOM, enabled, false)
	tl_value_set_done()
}
