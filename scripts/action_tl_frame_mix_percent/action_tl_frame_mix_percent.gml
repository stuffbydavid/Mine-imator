/// action_tl_frame_mix_percent(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_mix_percent, true)
tl_value_set(e_value.MIX_PERCENT, argument0 / 100, argument1)
tl_value_set_done()
