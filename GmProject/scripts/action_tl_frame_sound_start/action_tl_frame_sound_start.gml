/// action_tl_frame_sound_start(value, add)
/// @arg value
/// @arg add

function action_tl_frame_sound_start(val, add)
{
	tl_value_set_start(action_tl_frame_sound_start, true)
	tl_value_set(e_value.SOUND_START, val, add)
	tl_value_set_done()
	tl_update_length()
}
