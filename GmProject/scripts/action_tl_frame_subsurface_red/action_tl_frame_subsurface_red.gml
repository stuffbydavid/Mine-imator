function action_tl_frame_subsurface_red(value, add)
{
	tl_value_set_start(action_tl_frame_subsurface_red, true)
	tl_value_set(e_value.SUBSURFACE_RADIUS_RED, value / 100, add)
	tl_value_set_done()
}
