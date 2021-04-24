/// action_tl_frame_cam_shake(enable)
/// @arg enable

function action_tl_frame_cam_shake(enable)
{
	tl_value_set_start(action_tl_frame_cam_shake, false)
	tl_value_set(e_value.CAM_SHAKE, enable, false)
	tl_value_set_done()
}
