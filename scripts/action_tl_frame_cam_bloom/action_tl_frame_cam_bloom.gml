/// action_tl_frame_cam_bloom(enable)
/// @arg enable

function action_tl_frame_cam_bloom(enable)
{
	tl_value_set_start(action_tl_frame_cam_bloom, false)
	tl_value_set(e_value.CAM_BLOOM, enable, false)
	tl_value_set_done()
}
