/// action_tl_frame_cam_clrcor_contrast(value, add)
/// @arg value
/// @arg add

function action_tl_frame_cam_clrcor_contrast(val, add)
{
	tl_value_set_start(action_tl_frame_cam_clrcor_contrast, true)
	tl_value_set(e_value.CAM_CONTRAST, val / 100, add)
	tl_value_set_done()
}
