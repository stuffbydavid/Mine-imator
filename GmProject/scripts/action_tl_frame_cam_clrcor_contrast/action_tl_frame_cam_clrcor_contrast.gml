function action_tl_frame_cam_clrcor_contrast(value, add)
{
	tl_value_set_start(action_tl_frame_cam_clrcor_contrast, true)
	tl_value_set(e_value.CAM_CONTRAST, value / 100, add)
	tl_value_set_done()
}
