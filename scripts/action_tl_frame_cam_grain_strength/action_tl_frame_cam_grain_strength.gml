/// action_tl_frame_cam_grain_strength(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_cam_grain_strength, true)
tl_value_set(e_value.CAM_GRAIN_STRENGTH, argument0 / 100, argument1)
tl_value_set_done()
