/// action_tl_frame_cam_ca_red_offset(value, add)
/// @arg value
/// @arg add

function action_tl_frame_cam_ca_red_offset(val, add)
{
	tl_value_set_start(action_tl_frame_cam_ca_red_offset, true)
	tl_value_set(e_value.CAM_CA_RED_OFFSET, val / 100, add)
	tl_value_set_done()
}
