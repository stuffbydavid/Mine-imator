function action_tl_frame_cam_fx_exposure(value, add)
{
	tl_value_set_start(action_tl_frame_cam_fx_exposure, true)
	tl_value_set(e_value.CAM_FX_EXPOSURE, value, add)
	tl_value_set_done()
}
