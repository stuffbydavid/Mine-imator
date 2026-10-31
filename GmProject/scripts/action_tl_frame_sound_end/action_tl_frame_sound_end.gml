function action_tl_frame_sound_end(value, add)
{
	tl_value_set_start(action_tl_frame_sound_end, true)
	tl_value_set(e_value.SOUND_END, value, add)
	tl_value_set_done()
	tl_update_length()
}
