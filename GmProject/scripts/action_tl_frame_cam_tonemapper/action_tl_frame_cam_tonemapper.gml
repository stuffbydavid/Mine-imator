/// action_tl_frame_cam_tonemapper(tonemapper)
/// @arg tonemapper

function action_tl_frame_cam_tonemapper(tonemapper)
{
	tl_value_set_start(action_tl_frame_cam_tonemapper, false)
	tl_value_set(e_value.CAM_TONEMAPPER, tonemapper, false)
	tl_value_set_done()
}
