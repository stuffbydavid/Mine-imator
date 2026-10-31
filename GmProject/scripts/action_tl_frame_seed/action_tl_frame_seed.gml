function action_tl_frame_seed(value, add)
{
	tl_value_set_start(action_tl_frame_seed, true)
	tl_value_set(e_value.SEED, value, add)
	tl_value_set_done()
}
