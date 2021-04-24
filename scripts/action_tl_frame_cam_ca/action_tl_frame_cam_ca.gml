/// action_tl_frame_cam_ca(enable)
/// @arg enable

function action_tl_frame_cam_ca(enable)
{
	tl_value_set_start(action_tl_frame_cam_ca, false)
	tl_value_set(e_value.CAM_CA, enable, false)
	tl_value_set_done()
}
