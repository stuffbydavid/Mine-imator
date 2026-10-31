/// @arg view
/// @arg camera

function view_pick_depth(view, cam)
{
	if (window_busy != "pick_depth" || !content_mouseon)
		return 0

	mouse_cursor = cr_none
	if (!mouse_left_pressed || view.surface_width <= 0 || view.surface_height <= 0)
		return 0

	var hit, viewdepth;
	hit = view_raycast(view, mouse_x - content_x, mouse_y - content_y)
	viewdepth = project_render_distance

	if (hit[e_raycast.HIT])
	{
		if (!cam)
		{
			var focuscam, focuspos;
			focuscam = view_second.camera = view_camera_active ? timeline_camera : view_second.camera
			focuspos = view.surface_cam_from
			
			if (view_second.show && instance_exists(focuscam))
				focuspos = focuscam.world_pos

			viewdepth = clamp(round(point3D_distance(hit[e_raycast.POSITION], focuspos)), 0, project_render_distance)
		}
		else
			viewdepth = clamp(round(hit[e_raycast.DEPTH]), 0, project_render_distance)
	}

	camera_effect_type_edit = e_cam_fx.DOF
	action_tl_frame_cam_fx_dof_pick_depth(viewdepth)
	camera_effect_type_edit = null

	render_samples = -1
}
