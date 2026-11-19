function action_tl_frame_cam_fx_tonemapper(tonemapper)
{
	tl_value_set_start(action_tl_frame_cam_fx_tonemapper, false)
	tl_value_set(e_value.CAM_FX_TONEMAPPER, tonemapper, false)
	tl_value_set_done()
}
