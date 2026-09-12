/// action_tl_frame_cam_distort_zoom_amount(value, add)
/// @arg value
/// @arg add

function action_tl_frame_cam_distort_zoom_amount(val, add)
{
	tl_value_set_start(action_tl_frame_cam_distort_amount, true)
	tl_value_set(e_value.CAM_DISTORT_ZOOM_AMOUNT, val / 100, add)
	tl_value_set_done()
}
