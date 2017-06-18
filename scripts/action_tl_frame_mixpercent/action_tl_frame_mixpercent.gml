/// action_tl_frame_mixpercent(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_mixpercent, true)
tl_value_set(MIXPERCENT, argument0 / 100, argument1)
tl_value_set_done()
