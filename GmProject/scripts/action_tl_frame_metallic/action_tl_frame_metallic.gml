function action_tl_frame_metallic(value, add)
{
	tl_value_set_start(action_tl_frame_metallic, true)
	tl_value_set(e_value.METALLIC, value / 100, add)
	tl_value_set_done()
}
