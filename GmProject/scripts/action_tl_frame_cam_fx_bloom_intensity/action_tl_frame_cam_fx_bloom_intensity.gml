function action_tl_frame_cam_fx_bloom_intensity(value, add)
{
	tl_value_set_start(action_tl_frame_cam_fx_bloom_intensity, true)
	tl_value_set(e_value.CAM_FX_BLOOM_INTENSITY, value / 100, add)
	tl_value_set_done()
}
