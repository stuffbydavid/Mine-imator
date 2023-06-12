/// action_tl_frame_sound_pitch(value, add)
/// @arg value
/// @arg add

function action_tl_frame_sound_pitch(val, add)
{
	tl_value_set_start(action_tl_frame_sound_pitch, true)
	tl_value_set(e_value.SOUND_PITCH, val / 100, add)
	tl_value_set_done()
	tl_update_length()
}
