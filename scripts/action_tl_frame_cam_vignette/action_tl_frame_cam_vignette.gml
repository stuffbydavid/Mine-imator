/// action_tl_frame_cam_vignette(enable)
/// @arg enable

function action_tl_frame_cam_vignette(enable)
{
	tl_value_set_start(action_tl_frame_cam_vignette, false)
	tl_value_set(e_value.CAM_VIGNETTE, enable, false)
	tl_value_set_done()
}
