/// action_tl_frame_cam_clrcor(enable)
/// @arg enable

function action_tl_frame_cam_clrcor(enable)
{
	tl_value_set_start(action_tl_frame_cam_clrcor, false)
	tl_value_set(e_value.CAM_COLOR_CORRECTION, enable, false)
	tl_value_set_done()
}
