function action_tl_frame_cam_fx_fade(value, add)
{
	tl_value_set_start(action_tl_frame_cam_fx_fade, true)
	tl_value_set(e_value.MIX_PERCENT, value / 100, add)
	tl_value_set_done()
}
