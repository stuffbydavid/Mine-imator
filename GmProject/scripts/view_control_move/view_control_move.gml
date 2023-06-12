/// view_control_move(view)
/// @arg view

function view_control_move(view)
{
	var len, arrowstart, arrowend, mat;
	
	// Arrow length
	len = point3D_distance(cam_from, tl_edit.world_pos) * view_3d_control_size * view_control_ratio
	
	arrowstart = ((setting_tool_scale || setting_tool_transform) ? len - len/4 : len/7)
	arrowend = len
	
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
	
	// Draw axis arrows
	view_control_move_axis(view, e_view_control.POS_X, e_value.POS_X, c_control_red, control_pos(arrowstart, arrowend, X, mat, true), control_pos(arrowstart, arrowend, X, mat, false))
	view_control_move_axis(view, e_view_control.POS_Y, e_value.POS_Y, (setting_z_is_up ? c_control_green : c_control_blue), control_pos(arrowstart, arrowend, Y, mat, true), control_pos(arrowstart, arrowend, Y, mat, false))
	view_control_move_axis(view, e_view_control.POS_Z, e_value.POS_Z, (setting_z_is_up ? c_control_blue : c_control_green), control_pos(arrowstart, arrowend, Z, mat, true), control_pos(arrowstart, arrowend, Z, mat, false))
	
	// Draw each plane
	var ps, pe;
	ps = (len / 7)
	pe = ps + (len / 7.5)
	
	view_control_move_pan(view, len / 10)
	view_control_move_plane(view, e_view_control.POS_XY, point3D(1, 1, 0), (setting_z_is_up ? c_control_blue : c_control_green), mat, vec3(0, 0, 1), point3D(ps, ps, 0), point3D(pe, ps, 0), point3D(pe, pe, 0), point3D(ps, pe, 0)) // XY
	view_control_move_plane(view, e_view_control.POS_XZ, point3D(1, 0, 1), (setting_z_is_up ? c_control_green : c_control_blue), mat, vec3(0, 1, 0), point3D(ps, 0, ps), point3D(pe, 0, ps), point3D(pe, 0, pe), point3D(ps, 0, pe)) // XZ
	view_control_move_plane(view, e_view_control.POS_YZ, point3D(0, 1, 1), c_control_red, mat, vec3(1, 0, 0), point3D(0, ps, ps), point3D(0, pe, ps), point3D(0, pe, pe), point3D(0, ps, pe)) // YZ
	
	// Dragging plane
	if (window_busy = "rendercontrol" && view_control_edit_view = view && view_control_edit >= e_view_control.POS_XY && view_control_edit <= e_view_control.POS_PAN)
	{
		mouse_cursor = cr_handpoint
		
		// Move
		if (!mouse_still)
		{
			var move, pos, snapval;
			move = point3D_plane_intersect(view_control_plane_origin, view_control_plane_normal, cam_from, view_control_ray_dir)
			move = point3D_sub(move, view_control_plane_origin)
			move = vec3_mul_matrix(move, matrix_inverse(mat))
			pos = point3D(0, 0, 0)
			snapval = (dragger_snap ? setting_snap_size_position : snap_min)
			
			for (var i = X; i <= Z; i++)
			{
				if (i = Z && view_control_edit = e_view_control.POS_XY)
					continue
				else if (i = Y && view_control_edit = e_view_control.POS_XZ)
					continue
				else if (i = X && view_control_edit = e_view_control.POS_YZ)
					continue
				
				// Snap distance? (Local snap)
				if (!setting_snap_absolute && dragger_snap)
					move[i] = snap(move[i], snapval)
				
				move[i] /= tl_edit.value_inherit[e_value.SCA_X + axis_edit]
				
				// Add object value
				pos[i] = view_control_value[i] + move[i]
				
				// Clamp value
				pos[i] = tl_value_clamp(e_value.POS_X + i, pos[i])
				
				// Snap final value? (Absolute snap)
				if (setting_snap_absolute || !dragger_snap)
					pos[i] = snap(pos[i], snapval)
				
				// Get difference
				pos[i] -= tl_edit.value[e_value.POS_X + i]
			}
			
			// Update
			tl_value_set_start(action_tl_frame_pos_xyz, true)
			tl_value_set(e_value.POS_X, pos[X], true)
			tl_value_set(e_value.POS_Y, pos[Y], true)
			tl_value_set(e_value.POS_Z, pos[Z], true)
			tl_value_set_done()
		}
		
		// Release
		if (!mouse_left)
		{
			window_busy = ""
			view_control_edit = null
			view_control_plane = false
		}
	}
	else if (window_busy = "rendercontrol" && view_control_edit_view = view && view_control_edit >= e_view_control.POS_X && view_control_edit <= e_view_control.POS_Z) // Dragging axis arrow
	{
		mouse_cursor = cr_handpoint
		
		// Move
		var veclen = vec2_length(view_control_vec)
		if (veclen > 0 && !mouse_still)
		{
			var vecmouse, vecdot, move, snapval, newval;
			move = vec3(0)
			axis_edit = view_control_edit - e_view_control.POS_X
			
			// Find move factor
			vecmouse = vec2(mouse_dx, mouse_dy)
			vecdot = vec2_dot(vec2_normalize(view_control_vec), vec2_normalize(vecmouse))
			view_control_move_distance += (vec2_length(vecmouse) / veclen) * len * vecdot * dragger_multiplier * negate(view_control_flip)
			
			snapval = (dragger_snap ? setting_snap_size_position : snap_min)
			
			if (!setting_snap_absolute && dragger_snap)
				move[axis_edit] = snap(view_control_move_distance, snapval)
			else
				move[axis_edit] = view_control_move_distance
			
			for (var i = X; i <= Z; i++)
			{
				move[i] /= tl_edit.value_inherit[e_value.SCA_X + axis_edit]
				
				newval[i] = view_control_value[i] + move[i]
				
				newval[i] = tl_value_clamp(e_value.POS_X + i, newval[i])
				
				if ((setting_snap_absolute && move[i] != 0) || !dragger_snap)
					newval[i] = snap(newval[i], snapval)
				
				newval[i] -= tl_edit.value[e_value.POS_X + i]
			}
			
			// Update
			tl_value_set_start(action_tl_frame_pos_xyz, true)
			tl_value_set(e_value.POS_X, newval[X], true)
			tl_value_set(e_value.POS_Y, newval[Y], true)
			tl_value_set(e_value.POS_Z, newval[Z], true)
			tl_value_set_done()
		}
		
		// Release
		if (!mouse_left)
		{
			window_busy = ""
			view_control_edit = null
			view_control_value = 0
			view_control_flip = false
			view_control_move_distance = 0
		}
	}
}

// Returns true if position is closer to camera than selected object
function control_test_point(pos, tlpos, bias)
{
	var camdir = point3D_add(cam_from, vec3_mul(vec3_normalize(point3D_sub(cam_from, tlpos)), project_render_distance));
	var worlddis = clamp(vec3_dot(vec3_sub(tlpos, cam_from), vec3_sub(camdir, cam_from)) / vec3_length(vec3_sub(camdir, cam_from)), -no_limit, no_limit);
	var pointdis = clamp(vec3_dot(vec3_sub(pos,   cam_from), vec3_sub(camdir, cam_from)) / vec3_length(vec3_sub(camdir, cam_from)), -no_limit, no_limit);
	
	return (pointdis + bias < worlddis)
}

function control_pos(s, e, axis, mat, retstart)
{
	var startpos = vec3(0); startpos[axis] = s;
	var endpos = vec3(0); endpos[axis] = e;
	
	if (view_control_edit = null)
	{
		var endpos3d = vec3(0);
		endpos3d[axis] = point3D_distance(cam_from, tl_edit.world_pos) * view_3d_control_size * view_control_ratio
		endpos3d = point3D_mul_matrix(endpos3d, mat)
		
		if (control_test_point(endpos3d, tl_edit.world_pos, 0) && setting_gizmos_face_camera)
		{
			startpos = vec3_mul(startpos, -1)
			endpos = vec3_mul(endpos, -1)
		
			view_control_move_flip_axis[axis] = true
		}
		else
			view_control_move_flip_axis[axis] = false
	}
	else
	{
		if (view_control_move_flip_axis[axis])
		{
			startpos = vec3_mul(startpos, -1)
			endpos = vec3_mul(endpos, -1)
		}
	}
	
	if (retstart)
		return point3D_mul_matrix(startpos, mat)
	else
		return point3D_mul_matrix(endpos, mat)
}