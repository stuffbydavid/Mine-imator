function action_tl_frame_subsurface_blue(value, add)
{
	tl_value_set_start(action_tl_frame_subsurface_blue, true)
	tl_value_set(e_value.SUBSURFACE_RADIUS_BLUE, value / 100, add)
	tl_value_set_done()
}
