/// action_tl_frame_cam_bloom_intensity(value, add)
/// @arg value
/// @arg add

function action_tl_frame_cam_bloom_intensity(val, add)
{
	tl_value_set_start(action_tl_frame_cam_bloom_intensity, true)
	tl_value_set(e_value.CAM_BLOOM_INTENSITY, val / 100, add)
	tl_value_set_done()
}
