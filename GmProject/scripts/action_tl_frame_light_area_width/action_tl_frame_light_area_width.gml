function action_tl_frame_light_area_width(value, add)
{
	tl_value_set_start(action_tl_frame_light_area_width, true)
	tl_value_set(e_value.LIGHT_AREA_WIDTH, value, add)
	tl_value_set_done()
}
