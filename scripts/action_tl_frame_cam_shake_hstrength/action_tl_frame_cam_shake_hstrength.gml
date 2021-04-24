/// action_tl_frame_cam_shake_hstrength(value, add)
/// @arg value
/// @arg add

function action_tl_frame_cam_shake_hstrength(val, add)
{
	tl_value_set_start(action_tl_frame_cam_shake_hstrength, true)
	tl_value_set(e_value.CAM_SHAKE_HORIZONTAL_STRENGTH, val / 100, add)
	tl_value_set_done()
}
