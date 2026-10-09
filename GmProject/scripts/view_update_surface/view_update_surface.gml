/// @arg view
/// @arg camera
/// @arg watermark

function view_update_surface(view, cam, watermark)
{
	//debug("view_update_surface", view, cam, watermark)
	
	view.update = false
	view.update_gizmos = true
	render_view_current = view

	app_update_cameras(view.renderer, false)
	
	// Render
	renderer_current = view.renderer
	render_lights = (view.renderer != e_renderer.QUICK || setting_quick_mode_shading)
	render_particles = view.particles
	render_effects = (view = view_second && view.effects)
	render_background = !view.transparent_background
	render_watermark = watermark
	
	render_start(view.surface, cam, view, content_width, content_height)
	
	if (view.renderer = e_renderer.REALISTIC || view.renderer = e_renderer.STANDARD)
		render_high()
	else
		render_low()

	if (view = view_main && tl_focus != null && instance_exists(tl_focus))
	{
		tl_focus.world_pos_2d = view_shape_project(tl_focus.world_pos)
		cam_work_focus_2d_error = (point3D_project_error || tl_focus.world_pos_2d[X] < 0 || tl_focus.world_pos_2d[Y] < 0 || tl_focus.world_pos_2d[X] >= content_width || tl_focus.world_pos_2d[Y] >= content_height)
	}
	
	if (view.gizmos && !place_build)
	{
		// Selection
		if (tl_edit_amount > 0)
			view.surface_select = render_select(e_render_mode.SELECT, view.surface_select)
		
		if (!view.transparent_background && surface_exists(render_target))
		{
			surface_set_target(render_target)
			{
				gpu_set_blendmode_ext(bm_src_color, bm_one)
				draw_box(0, 0, render_width, render_height, false, c_black, 1)
				gpu_set_blendmode(bm_normal)
			}
			surface_reset_target()
		}
	}

	// Placed objects
	var showplace;
	if (place_build)
		showplace = content_mouseon || (build_structure != null && instance_exists(build_structure))
	else
		showplace = place_tl != null && (content_mouseon || place_content_mouseon = null)
	
	if (showplace)
	{
		view.surface_select = render_select(e_render_mode.PLACE_PARENT, view.surface_select)
		if (!place_build)
			view.surface_select = render_select(e_render_mode.PLACE_SELECT, view.surface_select)
	}
	
	// Save the view state
	view.surface_cam_from = point3D_copy(cam_from)
	view.surface_cam_to = point3D_copy(cam_to)
	view.surface_cam_up = point3D_copy(cam_up)
	view.surface_cam_fov = cam_fov
	view.surface_cam_near = cam_near
	view.surface_cam_far = cam_far
	view.surface_proj_matrix = array_copy_1d(proj_matrix)
	view.surface_view_matrix = array_copy_1d(view_matrix)
	view.surface_view_proj_matrix = array_copy_1d(view_proj_matrix)
	view.surface = render_done()
	view.surface_width = content_width
	view.surface_height = content_height
	view.surface_renderer = view.renderer
	view.surface_camera_last = cam
	view.surface_particles = view.particles
	view.surface_effects = view.effects
	view.surface_gizmos_enabled = view.gizmos
	view.surface_transparent_background = view.transparent_background
	view.surface_watermark = watermark
	view.surface_work_from = point3D_copy(cam_work_from)
	view.surface_work_angle = vec3(cam_work_angle_look_xy, cam_work_angle_look_z, cam_work_roll)
	
	// Keep accumulating Realistic samples until the image is finished
	if (view.renderer = e_renderer.REALISTIC && !render_samples_done)
		view_changed(view)
	
	render_background = true
	render_lights = true
	render_particles = true
}
