function action_tl_frame_light_area_height(value, add)
{
	tl_value_set_start(action_tl_frame_light_area_height, true)
	tl_value_set(e_value.LIGHT_AREA_HEIGHT, value, add)
	tl_value_set_done()
}
