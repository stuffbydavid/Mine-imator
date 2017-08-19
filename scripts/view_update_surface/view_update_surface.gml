/// view_update_surface(view, camera)
/// @arg view
/// @arg camera

var view, cam;
view = argument0
cam = argument1

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
	view.surface_select = render_select(view.surface_select)
	
	// Shapes and controls
	if (surface_exists(render_target))
	{
		surface_set_target(render_target)
		{
			// Shapes
			with (obj_timeline)
			{
				if (hide || !value_inherit[VISIBLE])
					continue
					
				draw_set_color(test(selected || parent_is_selected, c_white, c_controls))
				
				if (type = "spotlight")
					view_shape_spotlight()
				else if (type = "pointlight")
					view_shape_pointlight()
				else if (type = "camera" && id != cam)
					view_shape_camera()
				else if (type = "particles")
					view_shape_particles()
			}
			
			draw_set_color(c_white)
			
			// Controls
			if (tl_edit != null && tl_edit != cam)
			{
				if (!tl_edit.hide && tl_edit.value_inherit[VISIBLE])
				{
					if (tl_edit.value_type[POSITION] && app.frame_editor.position.show)
						view_control_position(view)
					if (tl_edit.value_type[ROTATION] && app.frame_editor.rotation.show)
						view_control_rotation(view)
					if (tl_edit.value_type[BEND] && app.frame_editor.bend.show)
						view_control_bend(view)
					if (tl_edit.value_type[CAMERA] && tl_edit.value[CAMROTATE] && app.frame_editor.camera.show)
						view_control_camera(view)
						
					view.control_mouseon_last = view.control_mouseon
					view.control_mouseon = null
				}
				
				// Update 2D position
				tl_edit.pos_2d = view_shape_project(tl_edit.pos)
				tl_edit.pos_2d_error = (point3D_project_error || tl_edit.pos_2d[X] < 0 || tl_edit.pos_2d[Y] < 0 || tl_edit.pos_2d[X] >= app.content_width || tl_edit.pos_2d[Y] >= app.content_height)
			}
			
		}
		surface_reset_target()
	}
}

view.surface = render_done()
render_lights = true
render_particles = true
