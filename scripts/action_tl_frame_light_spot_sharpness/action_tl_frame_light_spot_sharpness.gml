/// action_tl_frame_light_spot_sharpness(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_light_spot_sharpness, true)
tl_value_set(e_value.LIGHT_SPOT_SHARPNESS, argument0 / 100, argument1)
tl_value_set_done()
