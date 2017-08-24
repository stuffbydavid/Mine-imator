/// view_control_rotation_axis(view, valueid, color, matrix, length)
/// @arg view
/// @arg valueid
/// @arg color
/// @arg matrix
/// @arg length

var view, vid, color, mat, len, detail;
var pos3D, pos2D;
view = argument0
vid = argument1
color = argument2
mat = argument3
len = argument4

// Get middle
pos3D = point3D_mul_matrix(point3D(0, 0, 0), mat)
pos2D = view_shape_project(pos3D)
if (point3D_project_error)
	return 0

// Check state
if (window_busy = "rendercontrol")
{
	var facevec, camvec;
	
	if (view_control_edit != vid)
		return 0
		
	// Invert input?
	facevec = vec3_normalize(vec3_mul_matrix(vec3(0, 0, 1), mat))
	camvec = vec3_normalize(point3D_sub(cam_from, pos3D))
	view_control_flip = (vec3_dot(facevec, camvec) < 0)
	
	// Update dragging
	view_control_pos = pos2D
	draw_set_color(c_white)
}
else if (view.control_mouseon_last = vid)
{
	// Left click
	if (mouse_left_pressed)
	{
		window_busy = "rendercontrol"
		view_control_edit = vid
		view_control_edit_view = view
		view_control_value = tl_edit.value[vid]
		view_control_pos = pos2D
	}
	
	// Right click
	if (mouse_right_pressed && keyboard_check(vk_shift))
	{
		if (vid = e_value.BEND_ANGLE)
			action_tl_frame_bend_angle(0, false)
		else if (vid = e_value.CAM_ROTATE_ANGLE_XY)
			action_tl_frame_cam_rotate_angle_xy(0, false)
		else if (vid = e_value.CAM_ROTATE_ANGLE_Z)
			action_tl_frame_cam_rotate_angle_z(0, false)
		else
		{
			axis_edit = vid - e_value.ROT_X
			action_tl_frame_rot(0, false)
		}
		app_mouse_clear()
	}
	
	draw_set_color(c_white)
}
else
	draw_set_color(color)
	
// Circle
detail = 32
for (var i = 0; i <= 1; i += 1/detail)
{
	var start3D, start2D, end3D, end2D;
	
	// Convert to screen
	start3D = point3D_mul_matrix(point3D(cos(pi * 2*(i - 1/detail)) * len, sin(pi * 2*(i - 1/detail)) * len, 0), mat)
	start2D = view_shape_project(start3D)
	if (point3D_project_error)
		return 0
	
	end3D = point3D_mul_matrix(point3D(cos(pi * 2*i) * len, sin(pi * 2*i) * len, 0), mat)
	end2D = view_shape_project(end3D)
	if (point3D_project_error)
		return 0
		
	// Line
	view_shape_line_draw(start2D, end2D)
	
	// Check mouse
	if (content_mouseon && point_line_distance(start2D[X], start2D[Y], end2D[X], end2D[Y], mouse_x - content_x, mouse_y - content_y) < 8)
		view.control_mouseon = vid
}

draw_set_color(c_white)
