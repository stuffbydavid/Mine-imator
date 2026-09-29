function action_tl_frame_cam_clrcor(enabled)
{
	tl_value_set_start(action_tl_frame_cam_clrcor, false)
	tl_value_set(e_value.CAM_COLOR_CORRECTION, enabled, false)
	tl_value_set_done()
}
