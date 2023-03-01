/// action_tl_frame_cam_dof_gain(value, add)
/// @arg value
/// @arg add

function action_tl_frame_cam_dof_gain(val, add)
{
	tl_value_set_start(action_tl_frame_cam_dof_gain, true)
	tl_value_set(e_value.CAM_DOF_GAIN, val / 100, add)
	tl_value_set_done()
}
