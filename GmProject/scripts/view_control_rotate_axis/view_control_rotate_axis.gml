/// @arg view
/// @arg control
/// @arg valueid
/// @arg color
/// @arg matrix
/// @arg length

function view_control_rotate_axis(view, control, vid, color, mat, len)
{
	var detail, pos3d, pos2d, facevec, camvec, anglevis;
	detail = 64
	
	if (view_control_length != null)
		len = view_control_length
	
	// Get middle
	pos3d = point3D_mul_matrix(point3D(0), mat)
	pos2d = view_shape_project(pos3d)
	if (point3D_project_error)
		return 0
	
	facevec = vec3_normalize(vec3_mul_matrix(vec3(0, 0, 1), mat))
	camvec = vec3_normalize(point3D_sub(cam_from, pos3d))
	anglevis = abs(vec3_dot(facevec, camvec))
	
	var alpha = percent(anglevis, .05, .1);
	
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
		
		// Invert input?
		view_control_flip = (vec3_dot(facevec, camvec) < 0)
		
		// Update dragging
		view_control_pos = pos2d
		
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
			view_control_pos = pos2d
			view_control_matrix = mat
			view_control_length = len
		}
		
		// Right click
		if (mouse_right_pressed && keyboard_check(vk_shift))
		{
			if (control = e_view_control.ROT_X || control = e_view_control.ROT_Y || control = e_view_control.ROT_Z)
			{
				axis_edit = vid - e_value.ROT_X
				action_tl_frame_rot(0, false)
			}
			else if (control = e_view_control.BEND_X || control = e_view_control.BEND_Y || control = e_view_control.BEND_Z)
			{
				axis_edit = vid - e_value.BEND_ANGLE_X
				action_tl_frame_bend_angle(0, false)
			}
			else if (control = e_view_control.ROT_ANGLE_XY) 
				action_tl_frame_cam_rotate_angle_xy(0, false) 
			else if (control = e_view_control.ROT_ANGLE_Z) 
				action_tl_frame_cam_rotate_angle_z(0, false) 
			
			app_mouse_clear()
		}
		
		draw_set_color(c_white)
	}
	else
		draw_set_color(color)
	
	var start3d, start2d, end3d, end2d, v, vdot;
	v = point3D_sub(pos3d, cam_from)
	vdot = vec3_dot(v, v)
	
	// Convert start position to screen
	start3d = point3D_mul_matrix(point3D(cos(0) * len, sin(0) * len, 0), mat)
	start2d = view_shape_project(start3d)
	if (point3D_project_error)
	{
		draw_set_color(c_white)
		draw_set_alpha(1)
		
		return 0
	}
	
	// Draw circle
	var j = 0;
	for (var i = 0; i <= 1; i += 1/detail)
	{
		j++
		
		// Convert end position to screen
		end3d = point3D_mul_matrix(point3D(cos(pi * 2 * i) * len, sin(pi * 2 * i) * len, 0), mat)
		end2d = view_shape_project(end3d)
		if (point3D_project_error)
		{
			start3d = end3d
			start2d = end2d
			
			draw_set_color(c_white)
			draw_set_alpha(1)
			return 0
		}
		
		// Hide line in circle if behind world position
		if (view_control_edit != control)
		{	
			// Adjust full-wheel bias depending on distance
			var dis = lerp(0.001, .75, percent(point3D_distance(pos3d, cam_from), 0, 100));
			
			if (control_test_point(start3d, (vid - e_value.BEND_ANGLE_X) > Z ? tl_edit.world_pos_rotate : tl_edit.world_pos, dis * anglevis))
			{
				start3d = end3d
				start2d = end2d
				continue
			}
		}
		
		// Using 0 to set up start positions
		if (i > 0)
			view_shape_line_draw(start2d, end2d)
		
		// Check mouse
		if (place_tl = null && content_mouseon && point_line_distance(start2d[X], start2d[Y], end2d[X], end2d[Y], mouse_x - content_x, mouse_y - content_y) < view_3d_control_width / 2)
			view.control_mouseon = control
		
		// Set next start position as current end position
		start3d = end3d
		start2d = end2d
	}
	
	draw_set_color(c_white)
	draw_set_alpha(1)
}
