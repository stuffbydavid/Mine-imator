/// action_tl_frame_cam_vignette_strength(value, add)
/// @arg value
/// @arg add

function action_tl_frame_cam_vignette_strength(val, add)
{
	tl_value_set_start(action_tl_frame_cam_vignette_strength, true)
	tl_value_set(e_value.CAM_VIGNETTE_STRENGTH, val / 100, add)
	tl_value_set_done()
}
