/// action_tl_frame_light_strength(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_light_strength, true)
tl_value_set(e_value.LIGHT_STRENGTH, argument0 / 100, argument1)
tl_value_set_done()
