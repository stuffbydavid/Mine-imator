function action_tl_frame_cam_ca_red_offset(value, add)
{
	tl_value_set_start(action_tl_frame_cam_ca_red_offset, true)
	tl_value_set(e_value.CAM_CA_RED_OFFSET, value / 100, add)
	tl_value_set_done()
}
