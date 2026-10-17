function action_tl_frame_force_directional(value, add)
{
	tl_value_set_start(action_tl_frame_force_directional, true)
	tl_value_set(e_value.FORCE_DIRECTIONAL, value, add)
	tl_value_set_done()
}
