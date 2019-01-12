/// action_tl_frame_cam_grain_saturation(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_cam_grain_saturation, true)
tl_value_set(e_value.CAM_GRAIN_SATURATION, argument0 / 100, argument1)
tl_value_set_done()
