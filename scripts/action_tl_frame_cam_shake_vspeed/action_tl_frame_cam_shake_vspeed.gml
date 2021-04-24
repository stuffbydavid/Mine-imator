/// action_tl_frame_cam_shake_vspeed(value, add)
/// @arg value
/// @arg add

function action_tl_frame_cam_shake_vspeed(val, add)
{
	tl_value_set_start(action_tl_frame_cam_shake_vspeed, true)
	tl_value_set(e_value.CAM_SHAKE_VERTICAL_SPEED, val / 100, add)
	tl_value_set_done()
}
