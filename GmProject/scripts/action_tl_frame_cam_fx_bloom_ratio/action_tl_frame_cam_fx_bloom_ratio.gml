function action_tl_frame_cam_fx_bloom_ratio(value, add)
{
	tl_value_set_start(action_tl_frame_cam_fx_bloom_ratio, true)
	tl_value_set(e_value.CAM_FX_BLOOM_RATIO, value / 100, add)
	tl_value_set_done()
}
