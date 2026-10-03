function action_tl_frame_cam_fx_dof_preset(preset)
{
	tl_value_set_start(action_tl_frame_cam_fx_dof_preset, false)
	if (preset = 0)
	{
		tl_value_set(e_value.CAM_FX_DOF_DEPTH, 0)
		tl_value_set(e_value.CAM_FX_DOF_RANGE, 100)
	}
	else
	{
		tl_value_set(e_value.CAM_FX_DOF_DEPTH, project_render_distance)
		tl_value_set(e_value.CAM_FX_DOF_RANGE, project_render_distance - 200)
	}
	tl_value_set_done()
}
