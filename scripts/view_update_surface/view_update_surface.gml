/// view_update_surface(view, camera)
/// @arg view
/// @arg camera

function view_update_surface(view, cam)
{
	render_view_current = view
	
	with (obj_timeline)
		render_visible = tl_get_visible()
	
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
	
	if (view.gizmos || (view.boxes && app.setting_debug_features))
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
						
						if ((view.boxes && app.setting_debug_features) && tl.bounding_box_children.frustum_state != e_frustum_state.HIDDEN)
						{
							if (tl.scenery_repeat_bounding_box != null)
							{
								var chunks = [array_length(tl.scenery_repeat_bounding_box),
											  array_length(tl.scenery_repeat_bounding_box[0]),
											  array_length(tl.scenery_repeat_bounding_box[0][0]),
											  array_length(tl.scenery_repeat_bounding_box[0][0][0]),
											  array_length(tl.scenery_repeat_bounding_box[0][0][0][0]),
											  array_length(tl.scenery_repeat_bounding_box[0][0][0][0][0])];
								
								for (var rx = 0; rx < chunks[0]; rx++)
									for (var ry = 0; ry < chunks[1]; ry++)
										for (var rz = 0; rz < chunks[2]; rz++)
											for (var cx = 0; cx < chunks[3]; cx++)
												for (var cy = 0; cy < chunks[4]; cy++)
													for (var cz = 0; cz < chunks[5]; cz++)
														if (tl.scenery_repeat_bounding_box[rx][ry][rz][cx][cy][cz].changed)
															view_shape_box(tl.scenery_repeat_bounding_box[rx][ry][rz][cx][cy][cz].start_pos, tl.scenery_repeat_bounding_box[rx][ry][rz][cx][cy][cz].end_pos)
							}
							
							if (tl.bounding_box_matrix.changed)
							{
								draw_set_color(c_red)
								draw_set_alpha(.75)
								
								if (tl.bounding_box_matrix.frustum_state = e_frustum_state.VISIBLE)
									draw_set_color(c_lime)
								else if (tl.bounding_box_matrix.frustum_state = e_frustum_state.PARTIAL)
									draw_set_color(c_yellow)
								
								if (tl.model_timeline_list != null)
								{
									draw_set_color(c_aqua)
									draw_set_alpha(1)
								}
								
								view_shape_box(tl.bounding_box_matrix.start_pos, tl.bounding_box_matrix.end_pos)	
							}
							
							draw_set_alpha(1)
						}
					}	
				}
				
				draw_set_color(c_white)
				
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
