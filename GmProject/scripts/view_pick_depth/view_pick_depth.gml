/// @arg view
/// @arg camera

function view_pick_depth(view, cam)
{
	if (window_busy != "pick_depth")
		return 0

	if (!content_mouseon)
		return 0

	mouse_cursor = cr_none
	if (!mouse_left_pressed)
		return 0

	var mx, my, depthval;
	mx = mouse_x - content_x
	my = mouse_y - content_y
	
	// Use depth surface from last high-quality render
	if (view.renderer != e_renderer.QUICK && !window_place)
	{
		if (!surface_exists(view.surface_pick_depth_id))
			return 0
		
		var pixel = surface_getpixel(view.surface_pick_depth_id, mx, my);
		depthval = pixel[0]
		
		// Picked background
		if (surface_exists(view.surface_pick_mask_id) &&
			color_get_red(surface_getpixel_ext(view.surface_pick_mask_id, mx, my)) = 0)
			depthval = 1
	}
	else
	{
		var data = view_get_place_pixel(view, mx, my);
		depthval = data[2] = place_dir_none ? 1 : data[0]
	}
	
	var viewdepth = project_render_distance;
	if (depthval < 1)
	{
		var distance = lerp(view.surface_place_depth_near, view.surface_place_depth_far, depthval);
		
		// Work camera view
		if (!cam)
		{
			var clipspace, viewspace, hitpos, focuscam, focuspos;
			clipspace = vec4(mx / content_width * 2 - 1, (1 - my / content_height) * 2 - 1, 0, 1)
			viewspace = vec4_mul_matrix(clipspace, matrix_inverse_ext(view.surface_place_proj_matrix))
			viewspace = vec3_mul(viewspace, distance / viewspace[Z])
			hitpos = point3D_mul_matrix(viewspace, matrix_inverse_ext(view.surface_place_view_matrix))
			focuscam = view_second.camera = view_camera_active ? timeline_camera : view_second.camera
			focuspos = view.surface_cam_from
			if (view_second.show && instance_exists(focuscam))
				focuspos = focuscam.world_pos
			
			viewdepth = clamp(round(point3D_distance(hitpos, focuspos)), 0, project_render_distance)
		}
		
		// Camera view
		else
			viewdepth = clamp(round(distance), 0, project_render_distance)
	}

	camera_effect_type_edit = e_cam_fx.DOF
	action_tl_frame_cam_fx_dof_pick_depth(viewdepth)
	camera_effect_type_edit = null

	render_samples = -1
}
