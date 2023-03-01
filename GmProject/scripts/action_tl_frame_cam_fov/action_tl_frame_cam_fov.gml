/// action_tl_frame_cam_fov(value, add)
/// @arg value
/// @arg add

function action_tl_frame_cam_fov(val, add)
{
	tl_value_set_start(action_tl_frame_cam_fov, true)
	tl_value_set(e_value.CAM_FOV, val, add)
	tl_value_set_done()
}
