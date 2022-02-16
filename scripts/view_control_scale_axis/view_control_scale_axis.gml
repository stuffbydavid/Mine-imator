/// view_control_scale_axis(view, control, valueid, color, start, length, mat, axis, rotation)
/// @arg view
/// @arg control
/// @arg valueid
/// @arg color
/// @arg start
/// @arg length
/// @arg mat
/// @arg axis
/// @arg rotation

function view_control_scale_axis(view, control, vid, color, start, length, mat, axis, rotation)
{
	var s, e, axisarr, center3D, start3D, end3D, center2D, start2D, end2D;
	axisarr = [axis = X, axis = Y, axis = Z]
	s = control_pos(start, length, axis, mat, true)
	e = control_pos(start, length, axis, mat, false)
	
	if (view_control_move_flip_axis[axis])
		length *= -1
	
	center3D = point3D_mul_matrix(vec3(0), mat)
	start3D = s
	
	end3D = e
	
	// Convert to screen
	center2D = view_shape_project(center3D)
	if (point3D_project_error)
		return 0
	
	start2D = view_shape_project(start3D)
	if (point3D_project_error)
		return 0
	
	end2D = view_shape_project(end3D)
	if (point3D_project_error)
		return 0
	
	var alpha = percent(abs(vec3_dot(vec3_normalize(vec3_sub(end3D, center3D)), vec3_normalize(vec3_sub(cam_from, center3D)))), .975, .95);
	
	if ((window_busy = "rendercontrol" && view_control_edit = control) || view.control_mouseon_last = control)
		alpha = 1
	
	if (alpha = 0)
		return 0
	
	draw_set_alpha(alpha)
	
	// Check state
	if (window_busy = "rendercontrol")
	{
		if (view_control_edit != control || view_control_edit_view != view)
			return 0
		
		// Update dragging
		view_control_vec = point2D_sub(end2D, center2D)
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
			view_control_vec = point2D_sub(end2D, center2D)
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
	view_shape_line_draw(start2D, end2D)
	
	var size = (point3D_distance(cam_from, tl_edit.world_pos) * view_3d_control_size) * .035 * view_control_ratio;
	view_shape_cube_draw(mat, vec3_mul(axisarr, length), size)
	
	// Check mouse
	if (content_mouseon && (point_line_distance(start2D[X], start2D[Y], end2D[X], end2D[Y], mouse_x - content_x, mouse_y - content_y) < view_3d_control_width))
		view.control_mouseon = control
	
	draw_set_color(c_white)
	draw_set_alpha(1)
}
