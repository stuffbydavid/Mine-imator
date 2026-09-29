function action_tl_frame_cam_blade_stretch(value, add)
{
	tl_value_set_start(action_tl_frame_cam_blade_stretch, true)
	tl_value_set(e_value.CAM_BLADE_STRETCH, value / 100, add)
	tl_value_set_done()
}
