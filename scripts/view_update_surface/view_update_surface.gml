/// view_update_surface(view, camera)
/// @arg view
/// @arg camera

function view_update_surface(view, cam)
{
	render_view_current = view
	
	// Render
	render_lights = (view.quality != e_view_mode.FLAT)
	render_particles = view.particles
	render_effects = view.effects
	render_quality = view.quality
	render_debug_cascades = view.cascades
	render_start(view.surface, cam, content_width, content_height)
	
	if (view.quality = e_view_mode.RENDER)
		render_high()
	else
		render_low()
	
	if (view.gizmos)
	{
		// Selection
		if (tl_edit_amount > 0)
			view.surface_select = render_select(view.surface_select)
		
		// Shapes and controls
		if (surface_exists(render_target))
		{
			surface_set_target(render_target)
			{
				// Shapes
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
						else if (tl.type = e_temp_type.PARTICLE_SPAWNER)
							view_shape_particles(tl)
						else if (tl.type = e_tl_type.PATH)
							view_shape_path(tl)
						
						if (tl.selected && tl.type = e_tl_type.BODYPART && array_length(tl.part_joints_pos) > 0)
						{
							// Draw bones
							for (var i = 0; i < 2; i++)
								view_shape_bone(tl.part_joints_pos[i], point3D_distance(tl.part_joints_pos[i], tl.part_joints_pos[i + 1]), tl.part_joints_bone_matrix[i])
						}
					}
				}
				
				// Controls
				if (tl_edit != null && tl_edit != cam && view.gizmos)
				{
					var vis = tl_edit.render_visible;
					
					// Update 2D position
					tl_edit.world_pos_2d = view_shape_project(tl_edit.world_pos)
					tl_edit.world_pos_2d_error = (point3D_project_error || tl_edit.world_pos_2d[X] < 0 || tl_edit.world_pos_2d[Y] < 0 || tl_edit.world_pos_2d[X] >= content_width || tl_edit.world_pos_2d[Y] >= content_height)
					
					if (vis)
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
						
						view.control_mouseon_last = view.control_mouseon
						view.control_mouseon = null
						
						if (window_busy = "rendercontrol" && view_control_edit_view = view)
							app_mouse_wrap(content_x, content_y, content_width, content_height)
						
						if (!tl_edit.world_pos_2d_error)
							draw_circle_ext(tl_edit.world_pos_2d[X] + 1, tl_edit.world_pos_2d[Y] + 1, 6, false, 64, c_white, 1)
					}
				}
				
				// Alpha fix
				gpu_set_blendmode_ext(bm_src_color, bm_one)
				draw_box(0, 0, render_width, render_height, false, c_black, 1)
				gpu_set_blendmode(bm_normal)
			}
			surface_reset_target()
		}
	}
	
	view.surface = render_done()
	render_lights = true
	render_particles = true
}
