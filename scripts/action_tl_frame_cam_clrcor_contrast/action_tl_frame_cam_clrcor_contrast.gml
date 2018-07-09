/// action_tl_frame_cam_clrcor_contrast(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_cam_clrcor_contrast, true)
tl_value_set(e_value.CAM_CONTRAST, argument0 / 100, argument1)
tl_value_set_done()
