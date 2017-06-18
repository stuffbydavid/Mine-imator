/// action_tl_frame_set_light(color, range, fadesize, spotradius, spotsharpness)
/// @arg color
/// @arg range
/// @arg fadesize
/// @arg spotradius
/// @arg spotsharpness

tl_value_set_start(action_tl_frame_set_light, false)
tl_value_set(LIGHTCOLOR, argument0, false)
tl_value_set(LIGHTRANGE, argument1, false)
tl_value_set(LIGHTFADESIZE, argument2, false)
tl_value_set(LIGHTSPOTRADIUS, argument3, false)
tl_value_set(LIGHTSPOTSHARPNESS, argument4, false)
tl_value_set_done()
