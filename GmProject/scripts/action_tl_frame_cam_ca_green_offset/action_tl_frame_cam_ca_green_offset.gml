/// action_tl_frame_cam_ca_green_offset(value, add)
/// @arg value
/// @arg add

function action_tl_frame_cam_ca_green_offset(val, add)
{
	tl_value_set_start(action_tl_frame_cam_ca_green_offset, true)
	tl_value_set(e_value.CAM_CA_GREEN_OFFSET, val / 100, add)
	tl_value_set_done()
}
