function action_tl_frame_cam_lens_dirt_power(value, add)
{
	tl_value_set_start(action_tl_frame_cam_lens_dirt_power, true)
	tl_value_set(e_value.CAM_LENS_DIRT_POWER, value / 100, add)
	tl_value_set_done()
}
