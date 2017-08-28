/// action_tl_frame_lightspotsharpness(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_lightspotsharpness, true)
tl_value_set(LIGHTSPOTSHARPNESS, argument0 / 100, argument1)
tl_value_set_done()
