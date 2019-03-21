/// action_tl_frame_cam_bloom_ratio(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_cam_bloom_ratio, true)
tl_value_set(e_value.CAM_BLOOM_RATIO, argument0 / 100, argument1)
tl_value_set_done()
