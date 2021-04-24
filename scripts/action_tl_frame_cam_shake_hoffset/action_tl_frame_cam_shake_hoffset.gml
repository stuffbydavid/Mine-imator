/// action_tl_frame_cam_shake_hoffset(value, add)
/// @arg value
/// @arg add

function action_tl_frame_cam_shake_hoffset(val, add)
{
	tl_value_set_start(action_tl_frame_cam_shake_hoffset, true)
	tl_value_set(e_value.CAM_SHAKE_HORIZONTAL_OFFSET, val, add)
	tl_value_set_done()
}
