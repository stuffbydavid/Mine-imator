/// view_control_position_axis(view, valueid, color, start, end)
/// @arg view
/// @arg valueid
/// @arg color
/// @arg start
/// @arg end

var view, vid, color, start3D, end3D;
var start2D, end2D, ang;
view = argument0
vid = argument1
color = argument2
start3D = argument3
end3D = argument4

// Convert to screen
start2D = view_shape_project(start3D)
if (point3D_project_error)
	return 0

end2D = view_shape_project(end3D)
if (point3D_project_error)
	return 0

// Check state
if (window_busy = "rendercontrol")
{
	if (view_control_edit != vid)
		return 0

	// Update dragging
	view_control_vec = point2D_sub(end2D, start2D)
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
		view_control_vec = point2D_sub(end2D, start2D)
	}
	
	// Right click
	if (mouse_right_pressed && keyboard_check(vk_shift))
	{
		if (vid = e_value.CAM_ROTATE_DISTANCE)
			action_tl_frame_cam_rotate_distance(tl_edit.value_default[e_value.CAM_ROTATE_DISTANCE], false)
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
view_shape_line_draw(start2D, end2D)

// Arrow
ang = point_direction(start2D[X], start2D[Y], end2D[X], end2D[Y])
draw_image(spr_arrow, 0, end2D[X], end2D[Y], 1, 1, draw_get_color(), 1, ang)

// Check mouse
if (content_mouseon && point_line_distance(start2D[X], start2D[Y], end2D[X], end2D[Y], mouse_x - content_x, mouse_y - content_y) < control_width / 2)
	view.control_mouseon = vid
	
draw_set_color(c_white)
