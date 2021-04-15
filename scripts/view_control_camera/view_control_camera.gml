/// view_control_camera(view)
/// @arg view

var view, len, xyang, zang;
view = argument0
len = point3D_distance(cam_from, tl_edit.world_pos_rotate) * view_3d_control_size * 0.7

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

view_control_rotate_axis(view, e_view_control.ROT_ANGLE_XY, e_value.CAM_ROTATE_ANGLE_XY, c_axisyellow, xyang, len)
view_control_rotate_axis(view, e_view_control.ROT_ANGLE_Z, e_value.CAM_ROTATE_ANGLE_Z, c_axiscyan, zang, len)
view_control_move_axis(view, e_view_control.ROT_DISTANCE, e_value.CAM_ROTATE_DISTANCE, c_axismagenta, tl_edit.world_pos, tl_edit.world_pos_rotate, false)

// Is dragging
if (window_busy = "rendercontrol" && view_control_edit_view = view && (view_control_edit = e_view_control.ROT_ANGLE_XY || view_control_edit = e_view_control.ROT_ANGLE_Z))
{
	mouse_cursor = cr_handpoint
	
	if (!mouse_still)
	{
		var ang, prevang, rot, snapval, axesang, newval;
		
		// Find rotate amount
		ang = point_direction(mouse_x - content_x, mouse_y - content_y, view_control_pos[X], view_control_pos[Y])
		prevang = point_direction(mouse_previous_x - content_x, mouse_previous_y - content_y, view_control_pos[X], view_control_pos[Y])
		rot = angle_difference_fix(ang, prevang) * negate(view_control_flip)
		view_control_move_distance += rot * dragger_multiplier
		
		snapval = (dragger_snap ? setting_snap_size_rotation : snap_min)
		axesang = view_control_move_distance
		
		if (!setting_snap_absolute && dragger_snap)
			axesang = snap(axesang, snapval)
		
		newval = view_control_value + axesang
		
		if (view_control_edit = e_view_control.ROT_ANGLE_XY)
			newval = tl_value_clamp(e_value.CAM_ROTATE_ANGLE_XY, newval)
		else
			newval = tl_value_clamp(e_value.CAM_ROTATE_ANGLE_Z, newval)
		
		if (setting_snap_absolute || !dragger_snap)
			newval = snap(newval, snapval)
		
		if (view_control_edit = e_view_control.ROT_ANGLE_XY)
			newval -= tl_edit.value[e_value.CAM_ROTATE_ANGLE_XY]
		else
			newval -= tl_edit.value[e_value.CAM_ROTATE_ANGLE_Z]
		
		// Update
		if (view_control_edit = e_view_control.ROT_ANGLE_XY)
		{
			tl_value_set_start(action_tl_frame_cam_rotate_angle_xy, true)
			tl_value_set(e_value.CAM_ROTATE_ANGLE_XY, newval, true)
		}
		else
		{
			tl_value_set_start(action_tl_frame_cam_rotate_angle_z, true)
			tl_value_set(e_value.CAM_ROTATE_ANGLE_Z, newval, true)
		}
		
		if (frame_editor.camera.look_at_rotate)
		{
			if (view_control_edit = e_view_control.ROT_ANGLE_XY)
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
		view_control_matrix = null
		view_control_length = null
		view_control_move_distance = 0
		view_control_value = 0
	}
}

if (window_busy = "rendercontrol" && view_control_edit = e_view_control.ROT_DISTANCE)
{
	mouse_cursor = cr_handpoint
	
	// Move
	var veclen = vec2_length(view_control_vec)
	if (veclen > 0 && !mouse_still)
	{
		var vecmouse, vecdot, move, snapval, newval, dis;
		move = 0
		
		// Find move factor
		vecmouse = vec2(mouse_dx, mouse_dy)
		vecdot = vec2_dot(vec2_normalize(view_control_vec), vec2_normalize(vecmouse))
		dis = point3D_distance(tl_edit.world_pos, tl_edit.world_pos_rotate)
		view_control_move_distance -= vec2_length(vecmouse) * (dis / veclen) * vecdot * dragger_multiplier
		
		snapval = (dragger_snap ? setting_snap_size_position : snap_min)
		
		if (!setting_snap_absolute && dragger_snap)
			move = snap(view_control_move_distance, snapval)
		else
			move = view_control_move_distance
		
		newval = view_control_value + move
		newval = tl_value_clamp(e_value.CAM_ROTATE_DISTANCE, newval)
		
		if ((setting_snap_absolute && move != 0) || !dragger_snap)
			newval = snap(newval, snapval)
			
		newval -= tl_edit.value[e_value.CAM_ROTATE_DISTANCE]
		
		// Update
		tl_value_set_start(action_tl_frame_cam_rotate_distance, true)
		tl_value_set(e_value.CAM_ROTATE_DISTANCE, newval, true)
		tl_value_set_done()
	}
	
	// Release
	if (!mouse_left)
	{
		window_busy = ""
		view_control_edit = null
		view_control_matrix = null
		view_control_length = null
		view_control_move_distance = 0
		view_control_value = 0
	}
}
