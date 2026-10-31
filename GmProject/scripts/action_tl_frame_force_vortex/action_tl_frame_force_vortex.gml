function action_tl_frame_force_vortex(value, add)
{
	tl_value_set_start(action_tl_frame_force_vortex, true)
	tl_value_set(e_value.FORCE_VORTEX, value, add)
	tl_value_set_done()
}
