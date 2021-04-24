/// action_tl_frame_cam_clrcor_saturation(value, add)
/// @arg value
/// @arg add

function action_tl_frame_cam_clrcor_saturation(val, add)
{
	tl_value_set_start(action_tl_frame_cam_clrcor_saturation, true)
	tl_value_set(e_value.CAM_SATURATION, val / 100, add)
	tl_value_set_done()
}
