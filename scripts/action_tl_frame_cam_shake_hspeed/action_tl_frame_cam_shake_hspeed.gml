/// action_tl_frame_cam_shake_hspeed(value, add)
/// @arg value
/// @arg add

function action_tl_frame_cam_shake_hspeed(val, add)
{
	tl_value_set_start(action_tl_frame_cam_shake_hspeed, true)
	tl_value_set(e_value.CAM_SHAKE_HORIZONTAL_SPEED, val / 100, add)
	tl_value_set_done()
}
