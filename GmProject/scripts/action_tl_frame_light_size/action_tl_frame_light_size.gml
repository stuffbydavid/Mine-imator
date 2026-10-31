function action_tl_frame_light_size(value, add)
{
	tl_value_set_start(action_tl_frame_light_size, true)
	tl_value_set(e_value.LIGHT_SIZE, value, add)
	tl_value_set_done()
}
