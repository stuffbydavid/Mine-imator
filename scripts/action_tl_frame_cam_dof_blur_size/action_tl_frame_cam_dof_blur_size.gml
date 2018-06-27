/// action_tl_frame_cam_dof_blur_size(value, add)
/// @arg value
/// @arg add

tl_value_set_start(action_tl_frame_cam_dof_blur_size, true)
tl_value_set(e_value.CAM_DOF_BLUR_SIZE, argument0 / 100, argument1)
tl_value_set_done()
