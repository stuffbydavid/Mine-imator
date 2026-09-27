/// view_control_scale_all(view, mat, radius)
/// @arg view
/// @arg mat
/// @arg radius

function view_control_scale_all(view, mat, radius)
{
	var coord, radius2D, alpha;
	radius2D = ((radius / point3D_distance(tl_edit.world_pos, cam_from)) * content_height) / (cam_fov / 60)
	coord = point3D_project(matrix_position(mat), view_proj_matrix, content_width, content_height)
	
	if (point3D_project_error)
		return 0
	
	coord[X] = round(coord[X])
	coord[Y] = round(coord[Y])
	
	// Check state
	if (window_busy = "rendercontrol")
	{
		if (view_control_edit != e_view_control.SCA_XYZ || view_control_edit_view != view)
			return 0
		
		coord = view_control_scale_coords
		view_control_scale_amount = point_distance((mouse_wrap_x * content_width) + mouse_x - content_x, (mouse_wrap_y * content_height) + mouse_y - content_y, view_control_scale_coords[X], view_control_scale_coords[Y]) / view_control_scale_start
	}
	else if (view.control_mouseon_last = e_view_control.SCA_XYZ)
	{
		// Left click
		if (mouse_left_pressed)
		{
			window_busy = "rendercontrol"
			view_control_value_scale[X] = tl_edit.value[e_value.SCA_X]
			view_control_value_scale[Y] = tl_edit.value[e_value.SCA_Y]
			view_control_value_scale[Z] = tl_edit.value[e_value.SCA_Z]
			view_control_edit = e_view_control.SCA_XYZ
			view_control_edit_view = view
			view_control_scale_start = point_distance(mouse_x - content_x, mouse_y - content_y, coord[X], coord[Y])
			view_control_scale_amount = 1
			view_control_scale_coords[X] = coord[X]
			view_control_scale_coords[Y] = coord[Y]
			view_control_matrix = mat
		}
		
		// Right click
		if (mouse_right_pressed && keyboard_check(vk_shift))
		{
			axis_edit = X
			tl_value_set_start(action_tl_frame_scale, true)
			
			for (var i = X; i <= Z; i++)
				tl_value_set(e_value.SCA_X + i, tl_value_default(e_value.SCA_X + i), false)
			
			tl_value_set_done()
			app_mouse_clear()
		}
	}
	
	draw_set_color(c_control_white)
	
	// Draw circle
	if (view.control_mouseon_last = e_view_control.SCA_XYZ)
		alpha = 1
	else
		alpha = 0.6
	
	var drawcoord, mousecoord;
	drawcoord = coord
	mousecoord = point2D((mouse_wrap_x * content_width) + mouse_x - content_x, (mouse_wrap_y * content_height) + mouse_y - content_y)
	
	if (view_control_edit != e_view_control.SCA_XYZ)
	{
		draw_set_alpha(alpha)
		view_shape_circle(tl_edit.world_pos, radius)
	}
	else
	{
		draw_circle_ext(mousecoord[X], mousecoord[Y], 4, false, 16, c_black, 1)
		
		// Draw notches
		for (var i = 1; i < ceil(view_control_scale_amount * 8); i++)
		{
			var nx, ny, angle;
			nx = lerp(mousecoord[X], drawcoord[X], i/(view_control_scale_amount * 8))
			ny = lerp(mousecoord[Y], drawcoord[Y], i/(view_control_scale_amount * 8))
			
			if (nx > content_width || ny > content_height || nx < 0 || ny < 0)
				continue
			
			angle = -radtodeg(arctan2(mousecoord[Y] - drawcoord[Y], mousecoord[X] - drawcoord[X]))
			
			draw_line_ext(nx, ny, nx + lengthdir_x(5, angle), ny + lengthdir_y(5, angle), c_black, 1)
		}
	}
	
	// Check mouse
	if (place_tl = null && content_mouseon && (abs(point_distance(mouse_x - content_x, mouse_y - content_y, coord[X], coord[Y]) - radius2D) < view_3d_control_width/2))
		view.control_mouseon = e_view_control.SCA_XYZ
	
	draw_set_color(c_white)
	draw_set_alpha(1)
}
