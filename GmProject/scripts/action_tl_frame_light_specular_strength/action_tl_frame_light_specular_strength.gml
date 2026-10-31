function action_tl_frame_light_specular_strength(value, add)
{
	tl_value_set_start(action_tl_frame_light_specular_strength, true)
	tl_value_set(e_value.LIGHT_SPECULAR_STRENGTH, value / 100, add)
	tl_value_set_done()
}
