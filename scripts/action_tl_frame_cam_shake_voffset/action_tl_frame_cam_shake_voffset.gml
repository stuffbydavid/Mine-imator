/// action_tl_frame_cam_shake_voffset(value, add)
/// @arg value
/// @arg add

function action_tl_frame_cam_shake_voffset(val, add)
{
	tl_value_set_start(action_tl_frame_cam_shake_voffset, true)
	tl_value_set(e_value.CAM_SHAKE_VERTICAL_OFFSET, val, add)
	tl_value_set_done()
}
