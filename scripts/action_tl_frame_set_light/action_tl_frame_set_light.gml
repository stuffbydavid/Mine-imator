/// action_tl_frame_set_light(color, strength, size, range, fadesize, spotradius, spotsharpness)
/// @arg color
/// @arg strength
/// @arg size
/// @arg range
/// @arg fadesize
/// @arg spotradius
/// @arg spotsharpness

tl_value_set_start(action_tl_frame_set_light, false)
tl_value_set(e_value.LIGHT_COLOR, argument0, false)
tl_value_set(e_value.LIGHT_STRENGTH, argument1, false)
tl_value_set(e_value.LIGHT_SIZE, argument2, false)
tl_value_set(e_value.LIGHT_RANGE, argument3, false)
tl_value_set(e_value.LIGHT_FADE_SIZE, argument4, false)
tl_value_set(e_value.LIGHT_SPOT_RADIUS, argument5, false)
tl_value_set(e_value.LIGHT_SPOT_SHARPNESS, argument6, false)
tl_value_set_done()
