/// action_tl_frame_cam_lens_dirt_radius(value, add)
/// @arg value
/// @arg add

function action_tl_frame_cam_lens_dirt_radius(val, add)
{
	tl_value_set_start(action_tl_frame_cam_lens_dirt_radius, true)
	tl_value_set(e_value.CAM_LENS_DIRT_RADIUS, val / 100, add)
	tl_value_set_done()
}
