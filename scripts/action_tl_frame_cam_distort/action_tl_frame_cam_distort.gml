/// action_tl_frame_cam_distort(enable)
/// @arg enable

function action_tl_frame_cam_distort(enable)
{
	tl_value_set_start(action_tl_frame_cam_distort, false)
	tl_value_set(e_value.CAM_DISTORT, enable, false)
	tl_value_set_done()
}
