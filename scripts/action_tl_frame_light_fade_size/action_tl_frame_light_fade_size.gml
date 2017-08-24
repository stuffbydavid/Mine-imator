/// action_tl_frame_light_fade_size(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_light_fade_size, true)
tl_value_set(e_value.LIGHT_FADE_SIZE, argument0 / 100, argument1)
tl_value_set_done()
