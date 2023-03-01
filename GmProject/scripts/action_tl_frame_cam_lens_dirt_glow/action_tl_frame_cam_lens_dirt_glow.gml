/// action_tl_frame_cam_lens_dirt_glow(enable)
/// @arg enable

function action_tl_frame_cam_lens_dirt_glow(enable)
{
	tl_value_set_start(action_tl_frame_cam_lens_dirt_glow, false)
	tl_value_set(e_value.CAM_LENS_DIRT_GLOW, enable, false)
	tl_value_set_done()
}
