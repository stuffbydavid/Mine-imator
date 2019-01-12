/// action_tl_frame_cam_dof_fringe_all(fringe)
/// @arg fringe

tl_value_set_start(action_tl_frame_cam_dof_fringe_all, false)
tl_value_set(e_value.CAM_DOF_FRINGE_ANGLE_RED, argument0[@ X], false)
tl_value_set(e_value.CAM_DOF_FRINGE_ANGLE_GREEN, argument0[@ Y], false)
tl_value_set(e_value.CAM_DOF_FRINGE_ANGLE_BLUE, argument0[@ Z], false)
tl_value_set(e_value.CAM_DOF_FRINGE_RED, argument0[@ X + 3], false)
tl_value_set(e_value.CAM_DOF_FRINGE_GREEN, argument0[@ Y + 3], false)
tl_value_set(e_value.CAM_DOF_FRINGE_BLUE, argument0[@ Z + 3], false)
tl_value_set_done()
