function action_tl_frame_cam_fx_vignette_softness(value, add)
{
	tl_value_set_start(action_tl_frame_cam_fx_vignette_softness, true)
	tl_value_set(e_value.CAM_FX_VIGNETTE_SOFTNESS, value / 100, add)
	tl_value_set_done()
}
