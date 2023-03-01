/// action_tl_frame_cam_dof_fringe_green(value, add)
/// @arg value
/// @arg add

function action_tl_frame_cam_dof_fringe_green(val, add)
{
	tl_value_set_start(action_tl_frame_cam_dof_fringe_green, true)
	tl_value_set(e_value.CAM_DOF_FRINGE_GREEN, val / 100, add)
	tl_value_set_done()
}
