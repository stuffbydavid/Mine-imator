/// action_tl_frame_cam_distort_amount(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_cam_distort_amount, true)
tl_value_set(e_value.CAM_DISTORT_AMOUNT, argument0 / 100, argument1)
tl_value_set_done()
