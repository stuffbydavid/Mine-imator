function action_tl_frame_cam_shake(enabled)
{
	tl_value_set_start(action_tl_frame_cam_shake, false)
	tl_value_set(e_value.CAM_SHAKE, enabled, false)
	tl_value_set_done()
}
