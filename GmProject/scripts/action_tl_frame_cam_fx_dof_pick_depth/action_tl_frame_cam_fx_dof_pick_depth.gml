function action_tl_frame_cam_fx_dof_pick_depth(depth)
{
	tl_value_set_start(action_tl_frame_cam_fx_dof_pick_depth, false)
	tl_value_set(e_value.CAM_FX_DOF_DEPTH, depth)
	tl_value_set(e_value.CAM_FX_DOF_RANGE, max(100, depth - 200))
	tl_value_set_done()
}
