/// action_tl_frame_cam_dof_bias(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_cam_dof_bias, true)
tl_value_set(e_value.CAM_DOF_BIAS, argument0 / 10, argument1)
tl_value_set_done()
