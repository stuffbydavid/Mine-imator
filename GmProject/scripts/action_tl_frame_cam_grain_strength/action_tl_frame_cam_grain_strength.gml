function action_tl_frame_cam_grain_strength(value, add)
{
	tl_value_set_start(action_tl_frame_cam_grain_strength, true)
	tl_value_set(e_value.CAM_GRAIN_STRENGTH, value / 100, add)
	tl_value_set_done()
}
