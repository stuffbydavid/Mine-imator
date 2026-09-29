/// @arg view
/// @arg control
/// @arg valueid
/// @arg color
/// @arg start
/// @arg length
/// @arg matrix
/// @arg axis
/// @arg rotation

function view_control_scale_axis(view, control, vid, color, start, length, mat, axis, rotation)
{
	var s, e, axisarr, center3d, start3d, end3d, center2d, start2d, end2d;
	axisarr = [ (axis = X), (axis = Y), (axis = Z) ]
	s = control_pos(start, length, axis, mat, true)
	e = control_pos(start, length, axis, mat, false)
	
	if (view_control_move_flip_axis[axis])
		length *= -1
	
	center3d = point3D_mul_matrix(vec3(0), mat)
	start3d = s
	end3d = e
	
	// Convert to screen
	center2d = view_shape_project(center3d)
	if (point3D_project_error)
		return 0
	
	start2d = view_shape_project(start3d)
	if (point3D_project_error)
		return 0
	
	end2d = view_shape_project(end3d)
	if (point3D_project_error)
		return 0
	
	var alpha = percent(abs(vec3_dot(vec3_normalize(vec3_sub(end3d, center3d)), vec3_normalize(vec3_sub(cam_from, center3d)))), .975, .95);
	
	if ((window_busy = "rendercontrol" && view_control_edit = control) || view.control_mouseon_last = control || !setting_fade_gizmos)
		alpha = 1
	
	if (alpha = 0)
		return 0
	
	draw_set_alpha(alpha)
	
	// Check state
	if (window_busy = "rendercontrol")
	{
		if (view_control_edit != control || view_control_edit_view != view)
		{
			draw_set_color(c_white)
			draw_set_alpha(1)
			return 0
		}
		
		// Update dragging
		view_control_vec = point2D_sub(end2d, center2d)
		draw_set_color(c_white)
	}
	else if (view.control_mouseon_last = control)
	{
		// Left click
		if (mouse_left_pressed)
		{
			window_busy = "rendercontrol"
			view_control_edit = control
			view_control_edit_view = view
			view_control_value = tl_edit.value[vid]
			view_control_vec = point2D_sub(end2d, center2d)
			view_control_matrix = mat
			view_control_length = length
			view_control_move_distance = 0
		}
		
		// Right click
		if (mouse_right_pressed && keyboard_check(vk_shift))
		{
			axis_edit = vid - e_value.SCA_X
			action_tl_frame_scale(tl_value_default(vid), false)
			app_mouse_clear()
		}
		
		draw_set_color(c_white)
	}
	else
		draw_set_color(color)
	
	// Line
	view_shape_line_draw(start2d, end2d)
	
	var size = (point3D_distance(cam_from, tl_edit.world_pos) * view_3d_control_size) * .035 * view_control_ratio;
	view_shape_cube_draw(mat, vec3_mul(axisarr, length), size)
	
	// Check mouse
	if (place_tl = null && content_mouseon && (point_line_distance(start2d[X], start2d[Y], end2d[X], end2d[Y], mouse_x - content_x, mouse_y - content_y) < view_3d_control_width))
		view.control_mouseon = control
	
	draw_set_color(c_white)
	draw_set_alpha(1)
}
