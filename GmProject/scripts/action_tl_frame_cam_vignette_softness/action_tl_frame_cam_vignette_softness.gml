function action_tl_frame_cam_vignette_softness(value, add)
{
	tl_value_set_start(action_tl_frame_cam_vignette_softness, true)
	tl_value_set(e_value.CAM_VIGNETTE_SOFTNESS, value / 100, add)
	tl_value_set_done()
}
