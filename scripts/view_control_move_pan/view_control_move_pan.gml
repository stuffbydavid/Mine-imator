/// view_control_move_pan(view, radius)
/// @arg view
/// @arg radius

var view, radius, pos2D, end2D, radius2D, normal;
view = argument0
radius = argument1
pos2D = view_shape_project(tl_edit.world_pos)
end2D = view_shape_project(point3D_add(tl_edit.world_pos, point3D(0, 0, radius)))

radius2D = ((radius / point3D_distance(tl_edit.world_pos, cam_from)) * content_height) / (cam_fov / 60)

if (point3D_project_error)
	return 0

normal = vec3_normalize(point3D_sub(cam_from, tl_edit.world_pos))

// Check state
if (window_busy = "rendercontrol")
{
	if (view_control_edit != e_view_control.POS_PAN || view_control_edit_view != view)
		return 0
	
	view_control_plane_update()
	
	if (mouse_left_released)
	{
		window_busy = ""
		view_control_edit = null
	}
}
else if (view.control_mouseon_last = e_view_control.POS_PAN)
{
	// Left click
	if (mouse_left_pressed)
	{
		window_busy = "rendercontrol"
		view_control_edit = e_view_control.POS_PAN
		view_control_edit_view = view
		
		view_control_plane_start(tl_edit.world_pos, normal)
		view_control_value = point3D(tl_edit.value[e_value.POS_X], tl_edit.value[e_value.POS_Y], tl_edit.value[e_value.POS_Z])
	}
	
	// Right click
	if (mouse_right_pressed && keyboard_check(vk_shift))
	{
		tl_value_set_start(action_tl_frame_pos_xyz, true)
		
		for (var i = X; i <= Z; i++)
			tl_value_set(e_value.POS_X + i, tl_value_default(e_value.POS_X + i), false)
		
		tl_value_set_done()
		
		app_mouse_clear()
	}
}
else
	draw_set_alpha(.6)

view_shape_circle(tl_edit.world_pos, radius)

draw_set_alpha(1)

if (content_mouseon && (point_distance(pos2D[X], pos2D[Y], mouse_x - content_x, mouse_y - content_y) < radius2D))
	view.control_mouseon = e_view_control.POS_PAN
