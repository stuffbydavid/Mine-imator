/// action_tl_frame_cam_clrcor_saturation(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_cam_clrcor_saturation, true)
tl_value_set(e_value.CAM_SATURATION, argument0 / 100, argument1)
tl_value_set_done()
