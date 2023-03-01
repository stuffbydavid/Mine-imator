/// action_tl_frame_path_point_angle(value, add)
/// @arg value
/// @arg add

function action_tl_frame_path_point_angle(val, add)
{
	tl_value_set_start(action_tl_frame_path_point_angle, true)
	tl_value_set(e_value.PATH_POINT_ANGLE, val, add)
	tl_value_set_done()
}
