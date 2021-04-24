/// action_tl_frame_cam_dof_depth(value, add)
/// @arg value
/// @arg add

function action_tl_frame_cam_dof_depth(val, add)
{
	tl_value_set_start(action_tl_frame_cam_dof_depth, true)
	tl_value_set(e_value.CAM_DOF_DEPTH, val, add)
	tl_value_set_done()
}
