/// action_tl_frame_cam_ca_blur_amount(value, add)
/// @arg value
/// @arg add

function action_tl_frame_cam_ca_blur_amount(val, add)
{
	tl_value_set_start(action_tl_frame_cam_ca_blur_amount, true)
	tl_value_set(e_value.CAM_CA_BLUR_AMOUNT, val / 100, add)
	tl_value_set_done()
}
