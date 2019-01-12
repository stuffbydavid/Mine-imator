/// action_tl_frame_cam_dof_fringe_angle(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_cam_dof_fringe_angle, true)
tl_value_set(e_value.CAM_DOF_FRINGE_ANGLE_RED + axis_edit, argument0, argument1)
tl_value_set_done()
