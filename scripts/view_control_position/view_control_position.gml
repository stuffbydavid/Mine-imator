/// view_control_position(view)
/// @arg view

var view, len, mat;
view = argument0

// Arrow length
if (tl_edit.type = e_tl_type.CAMERA && tl_edit.value[e_value.CAM_ROTATE])
	len = point3D_distance(cam_from, tl_edit.world_pos_rotate) * 0.2
else
	len = point3D_distance(cam_from, tl_edit.world_pos) * 0.2

// Create matrix
with (tl_edit)
{
	// Start from the parent matrix (body part transforms included), restore the position and remove all scaling
	mat = array_copy_1d(matrix_parent)
	mat[MAT_X] = matrix[MAT_X]
	mat[MAT_Y] = matrix[MAT_Y]
	mat[MAT_Z] = matrix[MAT_Z]
	matrix_remove_scale(mat)
}

// Draw each axis
view_control_position_axis(view, e_value.POS_X, c_yellow, point3D_mul_matrix(vec3(-len, 0, 0), mat), point3D_mul_matrix(vec3(len, 0, 0), mat))
view_control_position_axis(view, e_value.POS_Y, test(setting_z_is_up, c_blue, c_red), point3D_mul_matrix(vec3(0, -len, 0), mat), point3D_mul_matrix(vec3(0, len, 0), mat))
view_control_position_axis(view, e_value.POS_Z, test(setting_z_is_up, c_red, c_blue), point3D_mul_matrix(vec3(0, 0, -len), mat), point3D_mul_matrix(vec3(0, 0, len), mat))

// Is dragging
if (window_busy = "rendercontrol" && view_control_edit_view = view && view_control_edit < e_value.ROT_X)
{
	mouse_cursor = cr_handpoint
	
	// Move
	var veclen = vec2_length(view_control_vec)
	if (veclen > 0 && !mouse_still)
	{
		var vecmouse, vecdot, move, snapval;
		
		// Find move factor
		vecmouse = vec2(mouse_dx, mouse_dy)
		vecdot = vec2_dot(vec2_normalize(view_control_vec), vec2_normalize(vecmouse))
		move = (vec2_length(vecmouse) / veclen) * len * 2*vecdot
		move /= tl_edit.value_inherit[e_value.SCA_X + view_control_edit]
		view_control_value += move
		
		// Snap
		snapval = frame_editor.position.snap_enabled * frame_editor.position.snap_size
		
		// Update
		axis_edit = view_control_edit
		tl_value_set_start(action_tl_frame_pos, true)
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
