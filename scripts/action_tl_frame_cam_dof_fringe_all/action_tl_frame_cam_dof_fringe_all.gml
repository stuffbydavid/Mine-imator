/// action_tl_frame_cam_dof_fringe_all(fringe)
/// @arg fringe

function action_tl_frame_cam_dof_fringe_all(fringe)
{
	tl_value_set_start(action_tl_frame_cam_dof_fringe_all, false)
	tl_value_set(e_value.CAM_DOF_FRINGE_ANGLE_RED, fringe[@ X], false)
	tl_value_set(e_value.CAM_DOF_FRINGE_ANGLE_GREEN, fringe[@ Y], false)
	tl_value_set(e_value.CAM_DOF_FRINGE_ANGLE_BLUE, fringe[@ Z], false)
	tl_value_set(e_value.CAM_DOF_FRINGE_RED, fringe[@ X + 3], false)
	tl_value_set(e_value.CAM_DOF_FRINGE_GREEN, fringe[@ Y + 3], false)
	tl_value_set(e_value.CAM_DOF_FRINGE_BLUE, fringe[@ Z + 3], false)
	tl_value_set_done()
}
