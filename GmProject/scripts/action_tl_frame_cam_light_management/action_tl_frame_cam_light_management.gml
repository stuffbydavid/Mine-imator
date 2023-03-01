/// action_tl_frame_cam_light_management(enable)
/// @arg enable

function action_tl_frame_cam_light_management(enable)
{
	tl_value_set_start(action_tl_frame_cam_light_management, false)
	tl_value_set(e_value.CAM_LIGHT_MANAGEMENT, enable, false)
	tl_value_set_done()
}
