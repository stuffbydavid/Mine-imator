function action_tl_frame_light_spot_sharpness(value, add)
{
	tl_value_set_start(action_tl_frame_light_spot_sharpness, true)
	tl_value_set(e_value.LIGHT_SPOT_SHARPNESS, value / 100, add)
	tl_value_set_done()
}
