/// action_tl_frame_bloom_threshold(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_cam_bloom_threshold, true)
tl_value_set(e_value.CAM_BLOOM_THRESHOLD, argument0 / 100, argument1)
tl_value_set_done()
