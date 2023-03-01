/// action_tl_frame_cam_blade_angle(value, add)
/// @arg value
/// @arg add

function action_tl_frame_cam_blade_angle(val, add)
{
	tl_value_set_start(action_tl_frame_cam_blade_angle, true)
	tl_value_set(e_value.CAM_BLADE_ANGLE, val, add)
	tl_value_set_done()
}
