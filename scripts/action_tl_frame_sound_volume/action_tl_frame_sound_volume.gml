/// action_tl_frame_sound_volume(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_sound_volume, true)
tl_value_set(e_value.SOUND_VOLUME, argument0 / 100, argument1)
tl_value_set_done()
