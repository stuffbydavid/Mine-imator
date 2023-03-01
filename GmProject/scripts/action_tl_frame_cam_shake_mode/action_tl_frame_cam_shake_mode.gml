/// action_tl_frame_cam_shake_mode(mode)
/// @arg mode

function action_tl_frame_cam_shake_mode(mode)
{
	tl_value_set_start(action_tl_frame_cam_shake_mode, false)
	tl_value_set(e_value.CAM_SHAKE_MODE, mode, false)
	tl_value_set_done()
}
