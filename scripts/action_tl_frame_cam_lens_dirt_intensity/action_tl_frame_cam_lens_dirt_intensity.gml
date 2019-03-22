/// action_tl_frame_cam_lens_dirt_intensity(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_cam_lens_dirt_intensity, true)
tl_value_set(e_value.CAM_LENS_DIRT_INTENSITY, argument0 / 100, argument1)
tl_value_set_done()
