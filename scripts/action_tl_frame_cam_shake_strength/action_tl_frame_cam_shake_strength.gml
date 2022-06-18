/// action_tl_frame_cam_shake_strength(value, add)
/// @arg value
/// @arg add

function action_tl_frame_cam_shake_strength(val, add)
{
	tl_value_set_start(action_tl_frame_cam_shake_strength, true)
	tl_value_set(e_value.CAM_SHAKE_STRENGTH_X + axis_edit, val / 100, add)
	tl_value_set_done()
}
