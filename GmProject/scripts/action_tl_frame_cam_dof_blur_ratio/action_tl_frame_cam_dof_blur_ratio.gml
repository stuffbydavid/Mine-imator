/// action_tl_frame_cam_dof_blur_ratio(value, add)
/// @arg value
/// @arg add

function action_tl_frame_cam_dof_blur_ratio(val, add)
{
	tl_value_set_start(action_tl_frame_cam_dof_blur_ratio, true)
	tl_value_set(e_value.CAM_DOF_BLUR_RATIO, val / 100, add)
	tl_value_set_done()
}
