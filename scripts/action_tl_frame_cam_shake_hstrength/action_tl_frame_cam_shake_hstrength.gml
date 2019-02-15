/// action_tl_frame_cam_shake_hstrength(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_cam_shake_hstrength, true)
tl_value_set(e_value.CAM_SHAKE_HORIZONTAL_STRENGTH, argument0 / 100, argument1)
tl_value_set_done()
