function action_tl_frame_roughness(value, add)
{
	tl_value_set_start(action_tl_frame_roughness, true)
	tl_value_set(e_value.ROUGHNESS, value / 100, add)
	tl_value_set_done()
}
