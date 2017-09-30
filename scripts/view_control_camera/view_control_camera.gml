/// view_control_camera(view)
/// @arg view

var view, len, xyang, zang;
view = argument0
len = point3D_distance(cam_from, tl_edit.world_pos_rotate) * 0.2 * 0.5

with (tl_edit)
{
	// Start from the parent matrix, set the position and remove all scaling
	xyang = array_copy_1d(matrix_parent)
	xyang[MAT_X] = world_pos_rotate[X]
	xyang[MAT_Y] = world_pos_rotate[Y]
	xyang[MAT_Z] = world_pos_rotate[Z]
	matrix_remove_scale(xyang)
}

zang = matrix_multiply(matrix_build(0, 0, 0, 90, 0, tl_edit.value[e_value.CAM_ROTATE_ANGLE_XY] + 90, 1, 1, 1), xyang)

view_control_rotation_axis(view, e_value.CAM_ROTATE_ANGLE_XY, c_aqua, xyang, len)
view_control_rotation_axis(view, e_value.CAM_ROTATE_ANGLE_Z, c_aqua, zang, len)
view_control_position_axis(view, e_value.CAM_ROTATE_DISTANCE, c_aqua, tl_edit.world_pos_rotate, tl_edit.world_pos)

// Is dragging
if (window_busy = "rendercontrol" && view_control_edit_view = view && (view_control_edit = e_value.CAM_ROTATE_ANGLE_XY || view_control_edit = e_value.CAM_ROTATE_ANGLE_Z))
{
	mouse_cursor = cr_handpoint
	
	if (!mouse_still)
	{
		var ang, prevang, rot;
		
		// Find rotate amount
		ang = point_direction(mouse_x - content_x, mouse_y - content_y, view_control_pos[X], view_control_pos[Y])
		prevang = point_direction(mouse_previous_x - content_x, mouse_previous_y - content_y, view_control_pos[X], view_control_pos[Y])
		rot = angle_difference_fix(ang, prevang) * test(view_control_flip, -1, 1)
		view_control_value += rot
		
		// Update
		axis_edit = view_control_edit
		
		if (view_control_edit = e_value.CAM_ROTATE_ANGLE_XY)
			tl_value_set_start(action_tl_frame_cam_rotate_angle_xy, true)
		else
			tl_value_set_start(action_tl_frame_cam_rotate_angle_z, true)
		
		tl_value_set(view_control_edit, view_control_value - tl_edit.value[view_control_edit], true)
		
		if (frame_editor.camera.look_at_rotate)
		{
			if (view_control_edit = e_value.CAM_ROTATE_ANGLE_XY)
				tl_value_set(e_value.ROT_Z, tl_edit.value[e_value.CAM_ROTATE_ANGLE_XY], false)
			else
				tl_value_set(e_value.ROT_X, tl_edit.value[e_value.CAM_ROTATE_ANGLE_Z], false)
		}
		
		tl_value_set_done()
	}
	
	// Release
	if (!mouse_left)
	{
		window_busy = ""
		view_control_edit = null
	}
}

if (window_busy = "rendercontrol" && view_control_edit = e_value.CAM_ROTATE_DISTANCE)
{
	mouse_cursor = cr_handpoint
	
	// Move
	var veclen = vec2_length(view_control_vec)
	if (veclen > 0 && !mouse_still)
	{
		var vecmouse, vecdot, dis, move;
		
		// Find move factor
		vecmouse = vec2(mouse_dx, mouse_dy)
		vecdot = vec2_dot(vec2_normalize(view_control_vec), vec2_normalize(vecmouse))
		dis = point3D_distance(tl_edit.world_pos, tl_edit.world_pos_rotate)
		move = vec2_length(vecmouse) * (dis / veclen) * vecdot
		view_control_value += move
		
		// Update
		axis_edit = view_control_edit
		tl_value_set_start(action_tl_frame_cam_rotate_distance, true)
		tl_value_set(view_control_edit, view_control_value - tl_edit.value[view_control_edit], true)
		tl_value_set_done()
	}
	
	// Release
	if (!mouse_left)
	{
		window_busy = ""
		view_control_edit = null
	}
}
