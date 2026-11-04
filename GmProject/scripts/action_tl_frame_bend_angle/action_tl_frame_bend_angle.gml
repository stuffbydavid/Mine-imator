function action_tl_frame_bend_angle(value, add)
{
	tl_value_set_start(action_tl_frame_bend_angle, true)
	tl_value_set(e_value.BEND_ANGLE_X + axis_edit, value, add)
	tl_value_set_done()
}
