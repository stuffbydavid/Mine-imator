function action_tl_frame_emissive(value, add)
{
	tl_value_set_start(action_tl_frame_emissive, true)
	tl_value_set(e_value.EMISSIVE, value / 100, add)
	tl_value_set_done()

}
