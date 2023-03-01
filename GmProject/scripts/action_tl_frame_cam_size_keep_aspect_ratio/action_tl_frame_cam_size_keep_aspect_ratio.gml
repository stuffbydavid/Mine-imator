/// action_tl_frame_cam_size_keep_aspect_ratio(enable)
/// @arg enable

function action_tl_frame_cam_size_keep_aspect_ratio(enable)
{
	tl_value_set_start(action_tl_frame_cam_size_keep_aspect_ratio, false)
	tl_value_set(e_value.CAM_SIZE_KEEP_ASPECT_RATIO, enable, false)
	tl_value_set_done()
}
