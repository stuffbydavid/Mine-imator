/// action_tl_frame_cam_bloom_blend(color)
/// @arg color

function action_tl_frame_cam_bloom_blend(color)
{
	tl_value_set_start(action_tl_frame_cam_bloom_blend, true)
	tl_value_set(e_value.CAM_BLOOM_BLEND, color, false)
	tl_value_set_done()
}
