/// action_tl_frame_cam_clrcor_brightness(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_cam_clrcor_brightness, true)
tl_value_set(e_value.CAM_BRIGHTNESS, argument0 / 100, argument1)
tl_value_set_done()
