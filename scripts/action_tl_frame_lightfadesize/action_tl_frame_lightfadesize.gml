/// action_tl_frame_lightfadesize(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_lightfadesize, true)
tl_value_set(LIGHTFADESIZE, argument0 / 100, argument1)
tl_value_set_done()
