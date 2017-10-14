/// view_control_bend(view)
/// @arg view

var view, len, part, mat;
view = argument0
len = point3D_distance(cam_from, tl_edit.world_pos) * 0.2 * 0.6
part = tl_edit.model_part

if (part.bend_axis = X)
	mat = matrix_multiply(matrix_build(0, 0, 0, 0, 90, 0, 1, 1, 1), tl_edit.matrix)
else if (part.bend_axis = Y)
	mat = matrix_multiply(matrix_build(0, 0, 0, 0, 90, 90, 1, 1, 1), tl_edit.matrix)
else
	mat = matrix_multiply(matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1), tl_edit.matrix)
	
matrix_remove_scale(mat)
view_control_rotation_axis(view, e_value.BEND_ANGLE, c_green, mat, len)

// Is dragging
if (window_busy = "rendercontrol" && view_control_edit_view = view && view_control_edit = e_value.BEND_ANGLE)
{
	mouse_cursor = cr_handpoint
	
	if (!mouse_still)
	{
		var ang, prevang, rot, snapval;
		
		// Find rotate amount
		ang = point_direction(mouse_x - content_x, mouse_y - content_y, view_control_pos[X], view_control_pos[Y])
		prevang = point_direction(mouse_previous_x - content_x, mouse_previous_y - content_y, view_control_pos[X], view_control_pos[Y])
		rot = angle_difference_fix(ang, prevang) * negate(view_control_flip) * negate(part.bend_invert) * negate(part.bend_direction != e_bend.FORWARD) * negate(part.bend_part = e_part.LEFT || part.bend_part = e_part.RIGHT)
		view_control_value += rot
		
		// Snap
		snapval = frame_editor.bend.snap_enabled * frame_editor.bend.snap_size
		
		// Update
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
