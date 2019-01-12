/// action_tl_frame_cam_dof_fringe_green(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_cam_dof_fringe_green, true)
tl_value_set(e_value.CAM_DOF_FRINGE_GREEN, argument0 / 100, argument1)
tl_value_set_done()
