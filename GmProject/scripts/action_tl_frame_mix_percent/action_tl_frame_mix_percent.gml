function action_tl_frame_mix_percent(value, add)
{
	tl_value_set_start(action_tl_frame_mix_percent, true)
	tl_value_set(e_value.MIX_PERCENT, value / 100, add)
	tl_value_set_done()
}
