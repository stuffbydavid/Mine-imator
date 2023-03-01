/// action_tl_frame_cam_grain(enable)
/// @arg enable

function action_tl_frame_cam_grain(enable)
{
	tl_value_set_start(action_tl_frame_cam_grain, false)
	tl_value_set(e_value.CAM_GRAIN, enable, false)
	tl_value_set_done()
}
