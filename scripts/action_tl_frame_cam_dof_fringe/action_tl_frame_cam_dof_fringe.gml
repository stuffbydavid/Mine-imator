/// action_tl_frame_cam_dof_fringe(enable)
/// @arg enable

function action_tl_frame_cam_dof_fringe(enable)
{
	tl_value_set_start(action_tl_frame_cam_dof_fringe, false)
	tl_value_set(e_value.CAM_DOF_FRINGE, enable, false)
	tl_value_set_done()
}
