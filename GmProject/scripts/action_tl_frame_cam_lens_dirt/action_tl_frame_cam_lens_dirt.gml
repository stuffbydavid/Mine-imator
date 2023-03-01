/// action_tl_frame_cam_lens_dirt(enable)
/// @arg enable

function action_tl_frame_cam_lens_dirt(enable)
{
	tl_value_set_start(action_tl_frame_cam_lens_dirt, false)
	tl_value_set(e_value.CAM_LENS_DIRT, enable, false)
	tl_value_set_done()
}
