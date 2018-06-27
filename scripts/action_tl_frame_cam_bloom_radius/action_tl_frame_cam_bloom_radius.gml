/// action_tl_frame_cam_bloom_radius(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_cam_bloom_radius, true)
tl_value_set(e_value.CAM_BLOOM_RADIUS, argument0 / 100, argument1)
tl_value_set_done()
