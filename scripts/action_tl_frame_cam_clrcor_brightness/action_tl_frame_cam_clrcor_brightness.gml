/// action_tl_frame_cam_clrcor_brightness(value, add)
/// @arg value
/// @arg add

function action_tl_frame_cam_clrcor_brightness(val, add)
{
	tl_value_set_start(action_tl_frame_cam_clrcor_brightness, true)
	tl_value_set(e_value.CAM_BRIGHTNESS, val / 100, add)
	tl_value_set_done()
}
