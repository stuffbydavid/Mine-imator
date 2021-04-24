/// action_tl_frame_cam_dof_range(value, add)
/// @arg value
/// @arg add

function action_tl_frame_cam_dof_range(val, add)
{
	tl_value_set_start(action_tl_frame_cam_dof_range, true)
	tl_value_set(e_value.CAM_DOF_RANGE, val, add)
	tl_value_set_done()
}
