function action_tl_frame_cam_clrcor_vibrance(value, add)
{
	tl_value_set_start(action_tl_frame_cam_clrcor_vibrance, true)
	tl_value_set(e_value.CAM_VIBRANCE, value / 100, add)
	tl_value_set_done()
}
