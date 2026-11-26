/// @arg view
/// @arg control
/// @arg valueid
/// @arg color
/// @arg start
/// @arg end
/// @arg [fade]

function view_control_move_axis(view, control, vid, color, start3d, end3d, fade = true)
{
	var center3d, center2d, start2d, end2d, alpha;
	center3d = tl_edit.world_pos
	
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
	
	alpha = fade ? percent(abs(vec3_dot(vec3_normalize(vec3_sub(end3d, center3d)), vec3_normalize(vec3_sub(cam_from, center3d)))), .975, .95) : 1
	
	if ((window_busy = "render/control" && view_control_edit = control) || view.control_mouseon_last = control || !setting_fade_gizmos)
		alpha = 1
	
	if (alpha = 0)
		return 0
	
	draw_set_alpha(alpha)
	
	// Check state
	if (window_busy = "render/control")
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
			window_busy = "render/control"
			view_control_edit = control
			view_control_edit_view = view
			
			if (vid <= Z)
				view_control_flip = view_control_move_flip_axis[vid]
			
			if (control = e_view_control.ROT_DISTANCE)
				view_control_value = tl_edit.value[e_value.CAM_ROTATE_DISTANCE]
			else
				view_control_value = point3D(tl_edit.value[e_value.POS_X], tl_edit.value[e_value.POS_Y], tl_edit.value[e_value.POS_Z])
			
			view_control_vec = point2D_sub(end2d, center2d)
			view_control_move_distance = 0
		}
		
		// Right click
		if (mouse_right_pressed && keyboard_check(vk_shift))
		{
			if (control = e_view_control.ROT_DISTANCE)
			{
				action_tl_frame_cam_rotate_distance(tl_edit.value_default[vid], false)
			}
			else
			{
				axis_edit = vid
				action_tl_frame_pos(tl_edit.value_default[vid], false)
			}
			
			app_mouse_clear()
		}
		
		draw_set_color(c_white)
	}
	else
		draw_set_color(color)
	
	// Line
	view_shape_line_draw(start2d, end2d)
	
	var rotation = point3D_angle(start3d, end3d);
	
	// Arrow
	var size = (point3D_distance(cam_from, control = e_view_control.ROT_DISTANCE ? tl_edit.world_pos_rotate : center3d) * view_3d_control_size) * .05 * view_control_ratio;
	view_shape_cone_draw(MAT_IDENTITY, end3d, rotation, size)
	
	// Check mouse
	if (place_tl = null && content_mouseon && point_line_distance(start2d[X], start2d[Y], end2d[X], end2d[Y], mouse_x - content_x, mouse_y - content_y) < view_3d_control_width / 2)
		view.control_mouseon = control
	
	draw_set_color(c_white)
	draw_set_alpha(1)
}
