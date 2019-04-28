/// action_tl_frame_cam_dof_threshold(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_cam_dof_threshold, true)
tl_value_set(e_value.CAM_DOF_THRESHOLD, argument0 / 100, argument1)
tl_value_set_done()
