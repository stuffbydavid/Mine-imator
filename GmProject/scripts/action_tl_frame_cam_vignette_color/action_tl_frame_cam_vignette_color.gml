/// action_tl_frame_cam_vignette_color(color)
/// @arg color

function action_tl_frame_cam_vignette_color(color)
{
	tl_value_set_start(action_tl_frame_cam_vignette_color, true)
	tl_value_set(e_value.CAM_VIGNETTE_COLOR, color, false)
	tl_value_set_done()
}
