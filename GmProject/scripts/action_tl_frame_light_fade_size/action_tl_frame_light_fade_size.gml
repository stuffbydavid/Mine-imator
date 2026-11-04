function action_tl_frame_light_fade_size(value, add)
{
	tl_value_set_start(action_tl_frame_light_fade_size, true)
	tl_value_set(e_value.LIGHT_FADE_SIZE, value / 100, add)
	tl_value_set_done()
}
