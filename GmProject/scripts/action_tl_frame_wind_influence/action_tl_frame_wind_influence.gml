function action_tl_frame_wind_influence(value, add)
{
	tl_value_set_start(action_tl_frame_wind_influence, true)
	tl_value_set(e_value.WIND_INFLUENCE, value / 100, add)
	tl_value_set_done()
}
