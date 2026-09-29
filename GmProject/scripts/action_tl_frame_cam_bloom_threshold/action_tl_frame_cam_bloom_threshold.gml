function action_tl_frame_cam_bloom_threshold(value, add)
{
	tl_value_set_start(action_tl_frame_cam_bloom_threshold, true)
	tl_value_set(e_value.CAM_BLOOM_THRESHOLD, value, add)
	tl_value_set_done()
}
