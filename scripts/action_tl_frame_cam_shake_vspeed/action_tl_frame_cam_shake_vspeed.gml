/// action_tl_frame_cam_shake_vspeed(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_cam_shake_vspeed, true)
tl_value_set(e_value.CAM_SHAKE_VERTICAL_SPEED, argument0 / 100, argument1)
tl_value_set_done()
