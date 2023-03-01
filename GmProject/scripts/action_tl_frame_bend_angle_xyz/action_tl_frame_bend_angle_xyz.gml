/// action_tl_frame_bend_angle_xyz(bend)
/// @arg bend

function action_tl_frame_bend_angle_xyz(bend)
{
	tl_value_set_start(action_tl_frame_bend_angle_xyz, false)
	tl_value_set(e_value.BEND_ANGLE_X, bend[@ X], false)
	tl_value_set(e_value.BEND_ANGLE_Y, bend[@ Y], false)
	tl_value_set(e_value.BEND_ANGLE_Z, bend[@ Z], false)
	tl_value_set_done()
}
