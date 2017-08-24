/// action_tl_frame_set_light(color, range, fadesize, spotradius, spotsharpness)
/// @arg color
/// @arg range
/// @arg fadesize
/// @arg spotradius
/// @arg spotsharpness

tl_value_set_start(action_tl_frame_set_light, false)
tl_value_set(e_value.LIGHT_COLOR, argument0, false)
tl_value_set(e_value.LIGHT_RANGE, argument1, false)
tl_value_set(e_value.LIGHT_FADE_SIZE, argument2, false)
tl_value_set(e_value.LIGHT_SPOT_RADIUS, argument3, false)
tl_value_set(e_value.LIGHT_SPOT_SHARPNESS, argument4, false)
tl_value_set_done()
