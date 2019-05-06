/// view_update_surface(view, camera)
/// @arg view
/// @arg camera

var view, cam;
view = argument0
cam = argument1

render_view_current = view

// Render
render_lights = view.lights
render_particles = view.particles
render_start(view.surface, cam, content_width, content_height)

if (view.render)
{
	render_high()
	
	if (render_time > setting_view_real_time_render_time || !setting_view_real_time_render)
	{
		view_render_real_time = false
		view.surface = render_done()
		return 0
	}
}
else
	render_low()

if (view.controls)
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
						
					draw_set_color(test((tl.selected || tl.parent_is_selected), c_white, c_controls))
				
					if (tl.type = e_tl_type.SPOT_LIGHT)
						view_shape_spotlight(tl)
					else if (tl.type = e_tl_type.POINT_LIGHT)
						view_shape_pointlight(tl)
					else if (tl.type = e_tl_type.CAMERA && tl != cam)
						view_shape_camera(tl)
					else if (tl.type = e_temp_type.PARTICLE_SPAWNER)
						view_shape_particles(tl)
				}
			}
			
			draw_set_color(c_white)
			
			// Controls
			if (tl_edit != null && tl_edit != cam)
			{
				if (!tl_edit.hide && tl_edit.value_inherit[e_value.VISIBLE] && (!(view.render && tl_edit.hq_hiding) && !(!view.render && tl_edit.lq_hiding)))
				{
					if (tl_edit.value_type[e_value_type.POSITION] && frame_editor.position.show)
						view_control_position(view)
					if (tl_edit.value_type[e_value_type.ROTATION] && frame_editor.rotation.show)
						view_control_rotation(view)
					if (tl_edit.value_type[e_value_type.BEND] && frame_editor.bend.show)
						view_control_bend(view)
					if (tl_edit.value_type[e_value_type.CAMERA] && tl_edit.value[e_value.CAM_ROTATE] && frame_editor.camera.show)
						view_control_camera(view)
						
					view.control_mouseon_last = view.control_mouseon
					view.control_mouseon = null
				}
				
				// Update 2D position
				tl_edit.world_pos_2d = view_shape_project(tl_edit.world_pos)
				tl_edit.world_pos_2d_error = (point3D_project_error || tl_edit.world_pos_2d[X] < 0 || tl_edit.world_pos_2d[Y] < 0 || tl_edit.world_pos_2d[X] >= content_width || tl_edit.world_pos_2d[Y] >= content_height)
			}
			
		}
		surface_reset_target()
	}
}

view.surface = render_done()
render_lights = true
render_particles = true
