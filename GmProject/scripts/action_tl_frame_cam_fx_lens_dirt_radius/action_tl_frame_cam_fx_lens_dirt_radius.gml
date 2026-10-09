function action_tl_frame_cam_fx_lens_dirt_radius(value, add)
{
	tl_value_set_start(action_tl_frame_cam_fx_lens_dirt_radius, true)
	tl_value_set(e_value.CAM_FX_LENS_DIRT_RADIUS, value / 100, add)
	tl_value_set_done()
}
