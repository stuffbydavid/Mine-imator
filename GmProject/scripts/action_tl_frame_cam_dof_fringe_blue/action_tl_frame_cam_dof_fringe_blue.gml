/// action_tl_frame_cam_dof_fringe_blue(value, add)
/// @arg value
/// @arg add

function action_tl_frame_cam_dof_fringe_blue(val, add)
{
	tl_value_set_start(action_tl_frame_cam_dof_fringe_blue, true)
	tl_value_set(e_value.CAM_DOF_FRINGE_BLUE, val / 100, add)
	tl_value_set_done()
}
