/// action_tl_frame_cam_bloom_transition(value, add)
/// @arg value
/// @arg add

function action_tl_frame_cam_bloom_transition(val, add)
{
	tl_value_set_start(action_tl_frame_cam_bloom_transition, true)
	tl_value_set(e_value.CAM_BLOOM_TRANSITION, val, add)
	tl_value_set_done()
}
