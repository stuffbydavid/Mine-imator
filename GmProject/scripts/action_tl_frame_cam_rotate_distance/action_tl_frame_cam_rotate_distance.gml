function action_tl_frame_cam_rotate_distance(value, add)
{
	tl_value_set_start(action_tl_frame_cam_rotate_distance, true)
	tl_value_set(e_value.CAM_ROTATE_DISTANCE, value, add)
	tl_value_set_done()
}
