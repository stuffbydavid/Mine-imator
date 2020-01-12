/// view_control_bend(view)
/// @arg view

var view, len, part;
view = argument0
len = point3D_distance(cam_from, tl_edit.world_pos) * view_3d_control_size * 0.45
part = tl_edit.model_part

for (var i = X; i <= Z; i++)
{
	if (!part.bend_axis[i])
		continue
	
	var mat;
	if (i = X)
		mat = matrix_multiply(matrix_build(0, 0, 0, 0, 90, tl_edit.value[e_value.BEND_ANGLE_Z] * part.bend_axis[Z], 1, 1, 1), tl_edit.matrix)
	else if (i = Y)
		mat = matrix_multiply(matrix_build(0, 0, 0, tl_edit.value[e_value.BEND_ANGLE_X] * part.bend_axis[X] + 90, 0, tl_edit.value[e_value.BEND_ANGLE_Z] * part.bend_axis[Z], 1, 1, 1), tl_edit.matrix)
	else
		mat = matrix_multiply(matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1), tl_edit.matrix)
	
	matrix_remove_scale(mat)
	view_control_rotation_axis(view, e_value.BEND_ANGLE_X + i, c_aqua, mat, len)
}

// Is dragging
if (window_busy = "rendercontrol" && view_control_edit_view = view && view_control_edit >= e_value.BEND_ANGLE_X && view_control_edit <= e_value.BEND_ANGLE_Z)
{
	mouse_cursor = cr_handpoint
	
	if (!mouse_still)
	{
		var axis, ang, prevang, rot, mul, snapval;
		
		// Find rotate amount
		axis = view_control_edit - e_value.BEND_ANGLE_X
		ang = point_direction(mouse_x - content_x, mouse_y - content_y, view_control_pos[X], view_control_pos[Y])
		prevang = point_direction(mouse_previous_x - content_x, mouse_previous_y - content_y, view_control_pos[X], view_control_pos[Y])
		rot = angle_difference_fix(ang, prevang) * negate(view_control_flip) * negate(part.bend_invert[axis]) * negate(axis = X)
		mul = min(1, (part.bend_direction_max[axis] - part.bend_direction_min[axis]) / 90)
		
		view_control_value += rot * mul
		
		// Snap
		snapval = frame_editor.bend.snap_enabled * frame_editor.bend.snap_size
		
		// Update
		axis_edit = view_control_edit
		tl_value_set_start(action_tl_frame_bend_angle, true)
		tl_value_set(view_control_edit, snap(view_control_value, snapval) - tl_edit.value[view_control_edit], true)
		tl_value_set_done()
	}
	
	// Release
	if (!mouse_left)
	{
		window_busy = ""
		view_control_edit = null
	}
}