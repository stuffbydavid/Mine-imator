/// action_tl_frame_cam_clrcor_color_burn(color)
/// @arg color

function action_tl_frame_cam_clrcor_color_burn(color)
{
	tl_value_set_start(action_tl_frame_cam_clrcor_color_burn, true)
	tl_value_set(e_value.CAM_COLOR_BURN, color, false)
	tl_value_set_done()
}
