function action_tl_frame_cam_gamma(value, add)
{
	tl_value_set_start(action_tl_frame_cam_gamma, true)
	tl_value_set(e_value.CAM_GAMMA, value, add)
	tl_value_set_done()
}
