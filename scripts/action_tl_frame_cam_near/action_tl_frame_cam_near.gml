/// action_tl_frame_cam_near(value, add)
/// @arg value
/// @arg add

function action_tl_frame_cam_near(val, add)
{
	tl_value_set_start(action_tl_frame_cam_near, true)
	tl_value_set(e_value.CAM_NEAR, val, add)
	tl_value_set_done()
}
