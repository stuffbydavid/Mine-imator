function action_tl_frame_cam_light_management(enabled)
{
	tl_value_set_start(action_tl_frame_cam_light_management, false)
	tl_value_set(e_value.CAM_LIGHT_MANAGEMENT, enabled, false)
	tl_value_set_done()
}
