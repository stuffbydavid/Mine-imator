/// action_tl_frame_cam_lens_dirt_bloom(enable)
/// @arg enable

function action_tl_frame_cam_lens_dirt_bloom(enable)
{
	tl_value_set_start(action_tl_frame_cam_lens_dirt_bloom, false)
	tl_value_set(e_value.CAM_LENS_DIRT_BLOOM, enable, false)
	tl_value_set_done()
}
