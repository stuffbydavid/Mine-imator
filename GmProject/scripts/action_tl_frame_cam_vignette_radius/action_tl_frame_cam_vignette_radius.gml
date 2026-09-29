function action_tl_frame_cam_vignette_radius(value, add)
{
	tl_value_set_start(action_tl_frame_cam_vignette_radius, true)
	tl_value_set(e_value.CAM_VIGNETTE_RADIUS, value / 100, add)
	tl_value_set_done()
}
