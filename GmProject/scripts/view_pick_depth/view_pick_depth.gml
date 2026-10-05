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

	view.surface_place_id = surface_require(view.surface_place_id, content_width, content_height)
	view.surface_place_normal = surface_require(view.surface_place_normal, content_width, content_height, false)
	if (!is_cpp())
		view.surface_place_depth_gm = surface_require(view.surface_place_depth_gm, content_width, content_height, false)

	render_start(null, cam, view, content_width, content_height)
	place_tl_render = false

	if (is_cpp())
		surface_clear_depth_cache(view.surface_place_id)
	surface_set_target_ext(0, view.surface_place_id)
	surface_set_target_ext(1, view.surface_place_normal)
	if (!is_cpp())
		surface_set_target_ext(2, view.surface_place_depth_gm)
	{
		gpu_set_blendmode_ext(bm_one, bm_zero)
		draw_clear_alpha(c_black, 0)
		render_world_start()
		render_world(e_render_mode.PLACE)
		render_world_done()
		gpu_set_blendmode(bm_normal)
	}
	surface_reset_target()
	render_done()
	place_tl_render = true
	view.update_place_surfaces = true

	var mx, my, depthval;
	mx = mouse_x - content_x
	my = mouse_y - content_y
	if (is_cpp())
		depthval = surface_get_depth(view.surface_place_id, mx, my)
	else
	{
		var packeddepth = surface_getpixel(view.surface_place_depth_gm, mx, my);
		packeddepth = color_get_red(packeddepth) / 255 + color_get_green(packeddepth) / (255 * 255) + color_get_blue(packeddepth) / (255 * 255 * 255)
		depthval = 1 - sqr(packeddepth)
	}

	var viewdepth = project_render_distance;
	if (depthval < 0.99975)
	{
		var clipspace, viewspace;
		clipspace = vec4(mx / content_width * 2 - 1, (1 - my / content_height) * 2 - 1, depthval * 2 - 1, 1)
		viewspace = vec4_homogenize(vec4_mul_matrix(clipspace, matrix_inverse_ext(proj_matrix)))
		
		// Work camera view
		if (!cam)
		{
			var hitpos, focuscam, focuspos;
			hitpos = point3D_mul_matrix(viewspace, matrix_inverse_ext(view_matrix))
			focuscam = view_second.camera = view_camera_active ? timeline_camera : view_second.camera
			focuspos = cam_from
			if (view_second.show && instance_exists(focuscam))
				focuspos = focuscam.world_pos
			
			viewdepth = clamp(round(point3D_distance(hitpos, focuspos)), 0, project_render_distance)
		}
		
		// Camera view
		else
			viewdepth = clamp(round(viewspace[Z]), 0, project_render_distance)
	}

	camera_effect_type_edit = e_cam_fx.DOF
	action_tl_frame_cam_fx_dof_pick_depth(viewdepth)
	camera_effect_type_edit = null

	render_samples = -1
}
