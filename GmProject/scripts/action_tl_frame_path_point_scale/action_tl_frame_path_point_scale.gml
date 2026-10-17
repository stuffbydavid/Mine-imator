function action_tl_frame_path_point_scale(value, add)
{
	tl_value_set_start(action_tl_frame_path_point_scale, true)
	tl_value_set(e_value.PATH_POINT_SCALE, value, add)
	tl_value_set_done()
}
