/// @arg view
/// @arg camera

function view_update_gizmos(view, cam)
{
	var prevcolor, prevalpha;
	prevcolor = draw_get_color()
	prevalpha = draw_get_alpha()
	
	view.update_gizmos = false
	view.surface_control_edit = view_control_edit
	view.control_mouseon = null
	
	// Re-use this view's camera without rendering the scene
	render_view_current = view
	render_camera = cam
	render_width = content_width
	render_height = content_height
	render_ratio = content_width / content_height
	cam_from = point3D_copy(view.surface_cam_from)
	cam_to = point3D_copy(view.surface_cam_to)
	cam_up = point3D_copy(view.surface_cam_up)
	cam_fov = view.surface_cam_fov
	cam_near = view.surface_cam_near
	cam_far = view.surface_cam_far
	cam_far_prev = cam_far
	proj_matrix = array_copy_1d(view.surface_proj_matrix)
	view_matrix = array_copy_1d(view.surface_view_matrix)
	view_proj_matrix = array_copy_1d(view.surface_view_proj_matrix)
	
	view.surface_gizmos = surface_require(view.surface_gizmos, content_width, content_height, false)
	
	render_set_projection_ortho(0, 0, content_width, content_height, 0)
	matrix_set(matrix_world, MAT_IDENTITY)
	gpu_set_ztestenable(false)
	
	draw_set_color(c_white)
	draw_set_alpha(1)
	
	surface_set_target(view.surface_gizmos)
	{
		draw_clear_alpha(c_black, 0)
		gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_inv_src_alpha)
		
		if (view.gizmos && !place_build)
		{
			// Shapes
			if (setting_overlay_view_shapes)
			{
				with (obj_timeline)
				{
					with (app)
					{
						var tl = other.id;
						if (tl.hide || !tl.value_inherit[e_value.VISIBLE])
							continue
					
						draw_set_color((tl.selected || tl.parent_is_selected) ? c_white : c_controls)
					
						if (tl.type = e_tl_type.SPOT_LIGHT)
							view_shape_spotlight(tl)
						else if (tl.type = e_tl_type.POINT_LIGHT)
							view_shape_pointlight(tl)
						else if (tl.type = e_tl_type.CAMERA && tl != cam)
							view_shape_camera(tl)
						else if (tl.type = e_tl_type.PARTICLE_SPAWNER)
							view_shape_particles(tl)
						else if (tl.type = e_tl_type.PATH)
							view_shape_path(view, tl)
					
						if (debug_show_bones && tl.selected && tl.type = e_tl_type.MODEL_PART && array_length(tl.part_joints_pos) > 0)
						{
							// Draw bones
							for (var i = 0; i < 2; i++)
								view_shape_bone(tl.part_joints_pos[i], point3D_distance(tl.part_joints_pos[i], tl.part_joints_pos[i + 1]), tl.part_joints_bone_matrix[i])
						}
					}
				}
			}
			
			// Controls
			if (setting_overlay_view_controls && tl_edit != null && tl_edit != cam)
			{
				var vis;
				with (tl_edit)
					vis = tl_get_visible()
				
				// Update 2D position
				tl_edit.world_pos_2d = view_shape_project(tl_edit.world_pos)
				tl_edit.world_pos_2d_error = (point3D_project_error || tl_edit.world_pos_2d[X] < 0 || tl_edit.world_pos_2d[Y] < 0 || tl_edit.world_pos_2d[X] >= content_width || tl_edit.world_pos_2d[Y] >= content_height)
				
				if (vis || view_control_edit)
				{
					view_control_ratio = 1//max(1, (100 / content_height) * 1.25)
					
					if (tl_edit.value_type[e_value_type.TRANSFORM_SCA] && (setting_tool_scale || setting_tool_transform))
						view_control_scale(view)
					
					if (tl_edit.value_type[e_value_type.CAMERA] && tl_edit.value[e_value.CAM_ROTATE])
						view_control_camera(view)
					
					if (tl_edit.value_type[e_value_type.TRANSFORM_POS] && (setting_tool_move || setting_tool_transform))
						view_control_move(view)
					
					if (tl_edit.value_type[e_value_type.TRANSFORM_ROT] && (setting_tool_rotate || setting_tool_transform))
						view_control_rotate(view)
					
					if (tl_edit.value_type[e_value_type.TRANSFORM_BEND] && setting_tool_bend)
						view_control_bend(view)
					
					if (window_busy = "render/control" && view_control_edit_view = view)
						app_mouse_wrap(content_x, content_y, content_width, content_height)
					
					if (!tl_edit.world_pos_2d_error && tl_edit.value_type[e_value_type.TRANSFORM_POS])
						draw_circle_ext(tl_edit.world_pos_2d[X] + 1, tl_edit.world_pos_2d[Y] + 1, 6, false, 64, c_white, 1)
				}
			}
			
			// Guides
			if (setting_overlay_view_guides)
			{
				with (obj_timeline)
				{
					with (app)
					{
						var tl = other.id;
						
						if (tl.hide || !tl.value_inherit[e_value.VISIBLE])
							continue
						
						if (tl.type = e_tl_type.SPOT_LIGHT && tl_edit = tl)
							view_shape_spotlight_guide(tl)
						else if (tl.type = e_tl_type.POINT_LIGHT && tl_edit = tl)
							view_shape_pointlight_guide(tl)
						
						else if (tl.type = e_tl_type.CAMERA)
						{
							// Use selected camera OR active camera
							if ((tl_edit = tl && tl != cam) || ((tl_edit = null || tl_edit.type != e_tl_type.CAMERA) && tl = timeline_camera))
								view_shape_camera_frustum(tl)
						}
					}
				}
			}
		}
	}
	
	surface_reset_target()
	gpu_set_blendmode(bm_normal)
	
	draw_set_color(prevcolor)
	draw_set_alpha(prevalpha)
	
	camera_apply(cam_window)
	
	// Draw the new hover highlight on the next overlay update
	if (view.control_mouseon_last != view.control_mouseon)
		view.update_gizmos = true
	
	view.control_mouseon_last = view.control_mouseon
	view.control_mouseon = null
	view.surface_tool_move = setting_tool_move
	view.surface_tool_rotate = setting_tool_rotate
	view.surface_tool_scale = setting_tool_scale
	view.surface_tool_bend = setting_tool_bend
	view.surface_tool_transform = setting_tool_transform
	view.surface_mouse_x = mouse_x - content_x
	view.surface_mouse_y = mouse_y - content_y
	view.surface_mouseon = content_mouseon
}
