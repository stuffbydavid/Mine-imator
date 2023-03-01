/// action_tl_frame_cam_grain_saturation(value, add)
/// @arg value
/// @arg add

function action_tl_frame_cam_grain_saturation(val, add)
{
	tl_value_set_start(action_tl_frame_cam_grain_saturation, true)
	tl_value_set(e_value.CAM_GRAIN_SATURATION, val / 100, add)
	tl_value_set_done()
}
