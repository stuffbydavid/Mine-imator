/// action_tl_frame_cam_grain_size(value, add)
/// @arg value
/// @arg add

function action_tl_frame_cam_grain_size(val, add)
{
	tl_value_set_start(action_tl_frame_cam_grain_size, true)
	tl_value_set(e_value.CAM_GRAIN_SIZE, val, add)
	tl_value_set_done()
}
