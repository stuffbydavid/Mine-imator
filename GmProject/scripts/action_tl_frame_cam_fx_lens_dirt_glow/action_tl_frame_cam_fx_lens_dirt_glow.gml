function action_tl_frame_cam_fx_lens_dirt_glow(enabled)
{
	tl_value_set_start(action_tl_frame_cam_fx_lens_dirt_glow, false)
	tl_value_set(e_value.CAM_FX_LENS_DIRT_GLOW, enabled, false)
	tl_value_set_done()
}
