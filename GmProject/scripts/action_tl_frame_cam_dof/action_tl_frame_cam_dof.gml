/// action_tl_frame_cam_dof(enable)
/// @arg enable

function action_tl_frame_cam_dof(enable)
{
	tl_value_set_start(action_tl_frame_cam_dof, false)
	tl_value_set(e_value.CAM_DOF, enable, false)
	tl_value_set_done()
}
