function action_tl_frame_light_range(value, add)
{
	tl_value_set_start(action_tl_frame_light_range, true)
	tl_value_set(e_value.LIGHT_RANGE, value, add)
	tl_value_set_done()
}
