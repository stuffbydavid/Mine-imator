/// action_tl_frame_cam_clrcor_vibrance(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_cam_clrcor_vibrance, true)
tl_value_set(e_value.CAM_VIBRANCE, argument0 / 100, argument1)
tl_value_set_done()
