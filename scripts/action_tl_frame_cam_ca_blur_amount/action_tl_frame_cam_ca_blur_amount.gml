/// action_tl_frame_cam_ca_blur_amount(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_cam_ca_blur_amount, true)
tl_value_set(e_value.CAM_CA_BLUR_AMOUNT, argument0 / 100, argument1)
tl_value_set_done()
