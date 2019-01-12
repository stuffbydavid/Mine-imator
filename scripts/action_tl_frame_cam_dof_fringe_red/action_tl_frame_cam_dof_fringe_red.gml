/// action_tl_frame_cam_dof_fringe_red(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_cam_dof_fringe_red, true)
tl_value_set(e_value.CAM_DOF_FRINGE_RED, argument0 / 100, argument1)
tl_value_set_done()
