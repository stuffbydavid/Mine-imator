function action_tl_frame_cam_fx_bloom_transition(value, add)
{
	tl_value_set_start(action_tl_frame_cam_fx_bloom_transition, true)
	tl_value_set(e_value.CAM_FX_BLOOM_TRANSITION, value, add)
	tl_value_set_done()
}
