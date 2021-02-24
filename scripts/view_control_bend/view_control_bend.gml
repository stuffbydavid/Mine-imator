/// view_control_bend(view)
/// @arg view

var view, len, part, color;
view = argument0
len = point3D_distance(cam_from, tl_edit.world_pos) * view_3d_control_size * 0.7
part = tl_edit.model_part

for (var i = X; i <= Z; i++)
{
	if (!part.bend_axis[i])
		continue
	
	var mat;
	if (i = X)
	{
		color = c_axiscyan
		mat = matrix_multiply(matrix_build(0, 0, 0, 0, 90, tl_edit.value[e_value.BEND_ANGLE_Z] * part.bend_axis[Z], 1, 1, 1), tl_edit.matrix)
	}
	else if (i = Y)
	{
		color = (setting_z_is_up ? c_axisyellow : c_axismagenta)
		mat = matrix_multiply(matrix_build(0, 0, 0, tl_edit.value[e_value.BEND_ANGLE_X] * part.bend_axis[X] + 90, 0, tl_edit.value[e_value.BEND_ANGLE_Z] * part.bend_axis[Z], 1, 1, 1), tl_edit.matrix)
	}
	else
	{
		color = (setting_z_is_up ? c_axismagenta : c_axisyellow)
		mat = matrix_multiply(matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1), tl_edit.matrix)
	}
	
	matrix_remove_scale(mat)
	view_control_rotation_axis(view, e_view_control.BEND_X + i, e_value.BEND_ANGLE_X + i, color, mat, len)
}

// Is dragging
if (window_busy = "rendercontrol" && view_control_edit_view = view && view_control_edit >= e_view_control.BEND_X && view_control_edit <= e_view_control.BEND_Z)
{
	mouse_cursor = cr_handpoint
	
	if (!mouse_still)
	{
		var ang, prevang, rot, snapval, mul, move;
		
		// Find rotate amount
		axis_edit = view_control_edit - e_view_control.BEND_X
		ang = point_direction(mouse_x - content_x, mouse_y - content_y, view_control_pos[X], view_control_pos[Y])
		prevang = point_direction(mouse_previous_x - content_x, mouse_previous_y - content_y, view_control_pos[X], view_control_pos[Y])
		rot = (angle_difference_fix(ang, prevang) * negate(view_control_flip) * negate(part.bend_invert[axis_edit]) * negate(axis_edit = X)) * dragger_multiplier 
		mul = min(1, (part.bend_direction_max[axis_edit] - part.bend_direction_min[axis_edit]) / 90)
		
		// Snap
		snapval = (dragger_snap ? setting_snap_size_rotation : snap_min)
		
		view_control_move_distance += rot * mul
		move = view_control_move_distance
		
		if (!setting_snap_absolute && dragger_snap)
			move = snap(move, snapval)
		
		move += view_control_value
		move = tl_value_clamp(e_value.BEND_ANGLE_X + axis_edit, move)
		
		if (setting_snap_absolute || !dragger_snap)
			move = snap(move, snapval)
		
		move -= tl_edit.value[e_value.BEND_ANGLE_X + axis_edit]
		
		// Update
		tl_value_set_start(action_tl_frame_bend_angle, true)
		tl_value_set(e_value.BEND_ANGLE_X + axis_edit, move, true)
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
