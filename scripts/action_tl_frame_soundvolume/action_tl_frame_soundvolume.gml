/// action_tl_frame_soundvolume(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_soundvolume, true)
tl_value_set(SOUNDVOLUME, argument0 / 100, argument1)
tl_value_set_done()
