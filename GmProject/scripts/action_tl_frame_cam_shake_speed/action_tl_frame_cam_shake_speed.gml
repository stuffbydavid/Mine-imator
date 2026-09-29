function action_tl_frame_cam_shake_speed(value, add)
{
	tl_value_set_start(action_tl_frame_cam_shake_speed, true)
	tl_value_set(e_value.CAM_SHAKE_SPEED_X + axis_edit, value / 100, add)
	tl_value_set_done()
}
