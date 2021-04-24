/// action_tl_frame_sound_volume(value, add)
/// @arg value
/// @arg add

function action_tl_frame_sound_volume(val, add)
{
	tl_value_set_start(action_tl_frame_sound_volume, true)
	tl_value_set(e_value.SOUND_VOLUME, val / 100, add)
	tl_value_set_done()
}
