/// action_tl_frame_cam_bloom_intensity(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_cam_bloom_intensity, true)
tl_value_set(e_value.CAM_BLOOM_INTENSITY, argument0 / 100, argument1)
tl_value_set_done()
