/// view_control_move_plane(view, control, axes, color, mat, normal, corner1, corner2, corner3, corner4)
/// @arg view
/// @arg control
/// @arg axes
/// @arg color
/// @arg mat
/// @arg normal
/// @arg corner1
/// @arg corner2
/// @arg corner3
/// @arg corner4

function view_control_move_plane(view, control, axes, color, mat, normal, corner1, corner2, corner3, corner4)
{
	normal = vec3_mul_matrix(normal, mat)
	
	for (var i = X; i <= Z; i++)
	{
		if (view_control_move_flip_axis[i])
		{
			corner1[i] *= -1
			corner2[i] *= -1
			corner3[i] *= -1
			corner4[i] *= -1
		}
	}
	
	// Corner 1
	var corner13D, corner12D;
	corner13D = point3D_mul_matrix(corner1, mat)
	corner12D = view_shape_project(corner13D)
	if (point3D_project_error)
		return 0
	
	// Corner 2
	var corner23D, corner22D;
	corner23D = point3D_mul_matrix(corner2, mat)
	corner22D = view_shape_project(corner23D)
	if (point3D_project_error)
		return 0
	
	// Corner 3
	var corner33D, corner32D;
	corner33D = point3D_mul_matrix(corner3, mat)
	corner32D = view_shape_project(corner33D)
	if (point3D_project_error)
		return 0
	
	// Corner 4
	var corner43D, corner42D;
	corner43D = point3D_mul_matrix(corner4, mat)
	corner42D = view_shape_project(corner43D)
	if (point3D_project_error)
		return 0
	
	// Flip normal
	if (vec3_dot(normal, vec3_normalize(point3D_sub(cam_from, matrix_position(mat)))) < 0)
		normal = vec3_mul(normal, -1)
	
	var alpha = percent(abs(vec3_dot(normal, vec3_normalize(point3D_sub(cam_from, matrix_position(mat))))), .1, .2);
	
	if (window_busy = "rendercontrol" && view_control_edit = control)
		alpha = 1
	
	if (alpha = 0 || (window_busy = "rendercontrol" && view_control_edit != control))
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
		
		view_control_plane_update()
		
		draw_set_color(c_white)
		
		if (mouse_left_released)
		{
			window_busy = ""
			view_control_edit = null
		}
	}
	else if (view.control_mouseon_last = control)
	{
		// Left click
		if (mouse_left_pressed)
		{
			window_busy = "rendercontrol"
			view_control_edit = control
			view_control_edit_view = view
			
			view_control_plane_start(tl_edit.world_pos, normal)
			
			view_control_value = point3D(tl_edit.value[e_value.POS_X], tl_edit.value[e_value.POS_Y], tl_edit.value[e_value.POS_Z])
			view_control_plane = true
		}
		
		// Right click
		if (mouse_right_pressed && keyboard_check(vk_shift))
		{
			tl_value_set_start(action_tl_frame_pos_xyz, true)
			
			for (var i = X; i <= Z; i++)
			{
				if (axes[i])
					tl_value_set(e_value.POS_X + i, tl_value_default(e_value.POS_X + i), false)
			}
			
			tl_value_set_done()
			
			app_mouse_clear()
		}
		
		draw_set_color(c_white)
	}
	else
		draw_set_color(color)
	
	// Draw outline
	view_shape_line_draw(corner12D, corner22D)
	view_shape_line_draw(corner22D, corner32D)
	view_shape_line_draw(corner32D, corner42D)
	view_shape_line_draw(corner42D, corner12D)
	
	// Draw square
	draw_set_alpha(.35)
	
	render_set_culling(false)
	draw_primitive_begin(pr_trianglelist)
	view_shape_triangle_draw(corner12D, corner22D, corner32D)
	view_shape_triangle_draw(corner32D, corner42D, corner12D)
	draw_primitive_end()
	render_set_culling(true)
	
	draw_set_color(c_white)
	draw_set_alpha(1)
	
	if ((point_in_triangle(mouse_x - content_x, mouse_y - content_y, corner12D[X], corner12D[Y], corner22D[X], corner22D[Y], corner32D[X], corner32D[Y]) || 
		point_in_triangle(mouse_x - content_x, mouse_y - content_y, corner12D[X], corner12D[Y], corner42D[X], corner42D[Y], corner32D[X], corner32D[Y])) && content_mouseon)
		view.control_mouseon = control
}
