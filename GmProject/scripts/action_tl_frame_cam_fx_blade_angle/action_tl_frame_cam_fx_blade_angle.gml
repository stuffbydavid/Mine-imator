function action_tl_frame_cam_fx_blade_angle(value, add)
{
	tl_value_set_start(action_tl_frame_cam_fx_blade_angle, true)
	tl_value_set(e_value.CAM_FX_BLADE_ANGLE, value, add)
	tl_value_set_done()
}
