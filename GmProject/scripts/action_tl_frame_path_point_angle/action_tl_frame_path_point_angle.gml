function action_tl_frame_path_point_angle(value, add)
{
	tl_value_set_start(action_tl_frame_path_point_angle, true)
	tl_value_set(e_value.PATH_POINT_ANGLE, value, add)
	tl_value_set_done()
}
