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
	
	mat = view_transform_gizmo_matrix(e_value_type.TRANSFORM_POS, mat)

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
			move = vec3_mul_matrix(move, matrix_inverse_ext(mat))
			if (view_control_transform_mode != e_rotation_space.GIMBAL)
			{
				var axes = [view_control_edit != e_view_control.POS_YZ, view_control_edit != e_view_control.POS_XZ, view_control_edit != e_view_control.POS_XY];
				view_transform_move_apply(move, axes)
			}
			else
			{
				pos = point3D(0)
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
			
			if (view_control_transform_mode != e_rotation_space.GIMBAL)
			{
				move[axis_edit] = view_control_move_distance
				var axes = vec3(0);
				axes[axis_edit] = 1
				view_transform_move_apply(move, axes)
			}
			else
			{
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

// Recover the position basis before tl_update_matrix removes inherited scale
// or rotation from matrix_parent. Translation still uses this original basis.
function view_transform_parent_matrix(timeline)
{
	var parent = timeline.parent;
	// Timeline dragging uses a temporary container with no transform of its own.
	// Keep the original parent basis until the item is dropped into its new parent.
	if (parent = app.timeline_move_obj)
		parent = timeline.move_parent
	var result = array_copy_1d(MAT_IDENTITY);
	if (parent != app)
	{
		result = array_copy_1d(timeline.inherit_rot_point ? parent.matrix_render : parent.matrix)
		if (parent.type = e_tl_type.MODEL_PART && timeline.lock_bend && parent.model_part != null && parent.model_part.bend_part != null)
		{
			var bend = vec3(parent.value_inherit[e_value.BEND_ANGLE_X], parent.value_inherit[e_value.BEND_ANGLE_Y], parent.value_inherit[e_value.BEND_ANGLE_Z]);
			result = matrix_multiply(model_part_get_bend_matrix(parent.model_part, bend, vec3(0)), result)
		}
	}
	if (timeline.type = e_tl_type.MODEL_PART && timeline.model_part != null)
		result = matrix_multiply(matrix_create(timeline.part_of != null ? timeline.model_part.position : vec3(0), timeline.model_part.rotation, vec3(1)), result)
	return result
}

function view_transform_basis_valid(mat, orthogonal)
{
	var x = vec3(mat[0], mat[1], mat[2]);
	var y = vec3(mat[4], mat[5], mat[6]);
	var z = vec3(mat[8], mat[9], mat[10]);
	if (min(vec3_length(x), vec3_length(y), vec3_length(z)) <= snap_min)
		return false
	x = vec3_normalize(x)
	y = vec3_normalize(y)
	z = vec3_normalize(z)
	if (abs(vec3_dot(vec3_cross(x, y), z)) < 0.00001)
		return false
	return !orthogonal || (abs(vec3_dot(x, y)) < 0.00001 && abs(vec3_dot(x, z)) < 0.00001 && abs(vec3_dot(y, z)) < 0.00001 && vec3_dot(vec3_cross(x, y), z) > 0)
}

function view_transform_space_update_selection()
{
	view_control_transform_selection = []
	view_control_transform_key_marker = noone
	view_control_transform_key_mixed = false
	with (obj_timeline)
		if (selected && (value_type[e_value_type.TRANSFORM_POS] || value_type[e_value_type.TRANSFORM_SCA]))
			other.view_control_transform_selection[array_length(other.view_control_transform_selection)] = id
	with (obj_keyframe)
	{
		if (!selected || !timeline.selected || (!timeline.value_type[e_value_type.TRANSFORM_POS] && !timeline.value_type[e_value_type.TRANSFORM_SCA]))
			continue
		if (other.view_control_transform_key_marker = noone)
			other.view_control_transform_key_marker = position
		else if (other.view_control_transform_key_marker != position)
			other.view_control_transform_key_mixed = true
	}
}

function view_transform_space_effective(transform_type)
{
	if (setting_rotation_space = e_rotation_space.GIMBAL || view_control_transform_key_mixed ||
		(view_control_transform_key_marker != noone && view_control_transform_key_marker != timeline_marker))
		return e_rotation_space.GIMBAL
	for (var i = 0; i < array_length(view_control_transform_selection); i++)
	{
		var timeline = view_control_transform_selection[i];
		if (!instance_exists(timeline) || !timeline.value_type[transform_type])
			continue
		if (timeline.lock || timeline.value[e_value.IK_TARGET] != null || timeline.value[e_value.PATH_OBJ] != null ||
			(timeline.part_of != null && timeline.part_of.inherit_pose))
			return e_rotation_space.GIMBAL
		var parent_basis = view_transform_parent_matrix(timeline);
		if (!view_transform_basis_valid(parent_basis, transform_type = e_value_type.TRANSFORM_SCA))
			return e_rotation_space.GIMBAL
		if (transform_type = e_value_type.TRANSFORM_SCA && (!timeline.inherit_rotation ||
			min(abs(timeline.value[e_value.SCA_X]), abs(timeline.value[e_value.SCA_Y]), abs(timeline.value[e_value.SCA_Z])) <= snap_min))
			return e_rotation_space.GIMBAL
	}
	return setting_rotation_space
}

function view_transform_orientation(timeline)
{
	var parent_basis = timeline.inherit_rotation ? view_rotation_matrix_orthonormal(view_transform_parent_matrix(timeline)) : MAT_IDENTITY;
	var local_basis = matrix_create(vec3(0), vec3(timeline.value[e_value.ROT_X], timeline.value[e_value.ROT_Y], timeline.value[e_value.ROT_Z]), vec3(1));
	return matrix_multiply(local_basis, parent_basis)
}

function view_transform_gizmo_matrix(transform_type, legacy_matrix)
{
	var dragging = window_busy = "rendercontrol" && view_control_transform_type = transform_type &&
		((view_control_edit >= e_view_control.POS_X && view_control_edit <= e_view_control.POS_PAN) ||
		 (view_control_edit >= e_view_control.SCA_X && view_control_edit <= e_view_control.SCA_XYZ));
	var mode = dragging ? view_control_transform_mode : view_transform_space_effective(transform_type);
	if (mode = e_rotation_space.GIMBAL)
		return legacy_matrix
	var result;
	if (dragging)
		result = array_copy_1d(view_control_transform_basis)
	else
		result = mode = e_rotation_space.LOCAL ? view_transform_orientation(tl_edit) : array_copy_1d(MAT_IDENTITY)
	result[MAT_X] = tl_edit.world_pos[X]
	result[MAT_Y] = tl_edit.world_pos[Y]
	result[MAT_Z] = tl_edit.world_pos[Z]
	return result
}

function view_transform_selected_ancestor(timeline, transform_type)
{
	var child = timeline;
	while (child.parent != app)
	{
		if (transform_type = e_value_type.TRANSFORM_POS ? !child.inherit_position : !child.inherit_scale)
			return false
		child = child.parent
		if (child.selected && child.value_type[transform_type])
			return true
	}
	return false
}

function view_transform_space_begin(transform_type)
{
	view_transform_space_update_selection()
	view_control_transform_type = transform_type
	view_control_transform_mode = view_transform_space_effective(transform_type)
	view_control_transform_history_started = false
	view_control_transform_start = []
	view_control_transform_parent_inverse = []
	view_control_transform_scale_basis = []
	ds_map_clear(view_control_transform_target_map)
	if (view_control_transform_mode = e_rotation_space.GIMBAL)
		return 0
	view_control_transform_basis = setting_rotation_space = e_rotation_space.LOCAL ? view_transform_orientation(tl_edit) : array_copy_1d(MAT_IDENTITY)
	view_control_transform_origin = vec3_mul_matrix(tl_edit.world_pos, matrix_inverse_ext(view_control_transform_basis))
	with (obj_timeline)
	{
		if (!selected || !value_type[other.view_control_transform_type] || view_transform_selected_ancestor(id, other.view_control_transform_type))
			continue
		var index = array_length(other.view_control_transform_start);
		var vid = other.view_control_transform_type = e_value_type.TRANSFORM_POS ? e_value.POS_X : e_value.SCA_X;
		other.view_control_transform_start[index] = vec3(value[vid], value[vid + 1], value[vid + 2])
		ds_map_add(other.view_control_transform_target_map, save_id_get(id), index)
		var parent_basis = view_transform_parent_matrix(id);
		other.view_control_transform_parent_inverse[index] = inherit_position ? matrix_inverse_ext(parent_basis) : MAT_IDENTITY
		// Normal scaling follows parent axes (R*S*P). Resize scaling follows
		// the object's rotated axes (S*R*P), as in tl_update_matrix.
		other.view_control_transform_scale_basis[index] = (scale_resize || !inherit_scale || type = e_tl_type.PARTICLE_SPAWNER) ? view_transform_orientation(id) : parent_basis
	}
	return 0
}

function view_transform_space_write(values_x, values_y, values_z)
{
	if (array_length(values_x) = 0)
		return 0
	var position = view_control_transform_type = e_value_type.TRANSFORM_POS;
	var vid = position ? e_value.POS_X : e_value.SCA_X;
	tl_value_set_start_targets(position ? action_tl_frame_pos_xyz : action_tl_frame_scale_xyz, view_control_transform_history_started, view_control_transform_target_map)
	view_control_transform_history_started = true
	tl_value_set_target_values(vid, view_control_transform_target_map, values_x)
	tl_value_set_target_values(vid + 1, view_control_transform_target_map, values_y)
	tl_value_set_target_values(vid + 2, view_control_transform_target_map, values_z)
	tl_value_set_done()
	return 0
}

function view_transform_move_apply(move, axes)
{
	var snapval = dragger_snap ? setting_snap_size_position : snap_min;
	for (var axis = X; axis <= Z; axis++)
	{
		if (!axes[axis])
			move[axis] = 0
		else if (setting_snap_absolute)
			move[axis] = snap(view_control_transform_origin[axis] + move[axis], snapval) - view_control_transform_origin[axis]
		else
			move[axis] = snap(move[axis], snapval)
	}
	var world_delta = vec3_mul_matrix(move, view_control_transform_basis);
	if (vec3_length(world_delta) < snap_min && !view_control_transform_history_started)
		return 0
	var values_x = [], values_y = [], values_z = [];
	for (var i = 0; i < array_length(view_control_transform_start); i++)
	{
		// Each selected root has its own parent coordinates. Inverting that
		// basis gives every root the same world displacement, even when scaled.
		var delta = vec3_mul_matrix(world_delta, view_control_transform_parent_inverse[i]);
		var result = vec3_add(view_control_transform_start[i], delta);
		values_x[i] = result[X]
		values_y[i] = result[Y]
		values_z[i] = result[Z]
	}
	return view_transform_space_write(values_x, values_y, values_z)
}

function view_transform_scale_factors(move, axes)
{
	var factors = vec3(1);
	var snapval = dragger_snap ? setting_snap_size_scale : snap_min;
	for (var axis = X; axis <= Z; axis++)
		if (axes[axis])
			factors[axis] = 1 + (setting_snap_absolute ? move[axis] : snap(move[axis], snapval))
	return factors
}

function view_transform_scale_project(start_scale, channel_basis, stretch)
{
	var result = vec3(1);
	for (var axis = X; axis <= Z; axis++)
	{
		var direction = vec3(channel_basis[axis * 4], channel_basis[axis * 4 + 1], channel_basis[axis * 4 + 2]);
		var stretched = vec3_mul_matrix(direction, stretch);
		var factor = vec3_length(stretched) / vec3_length(direction);
		if (vec3_dot(direction, stretched) < 0)
			factor = -factor
		result[axis] = start_scale[axis] * factor
	}
	return result
}

function view_transform_scale_apply(factors)
{
	if (vec3_length(vec3_sub(factors, vec3(1))) < snap_min && !view_control_transform_history_started)
		return 0
	// Express the requested stretch in world coordinates, then measure it on
	// each stored scale axis. Keep rotation fixed: our channels cannot store shear.
	var stretch = matrix_multiply(matrix_multiply(matrix_inverse_ext(view_control_transform_basis), matrix_create(vec3(0), vec3(0), factors)), view_control_transform_basis);
	var values_x = [], values_y = [], values_z = [];
	for (var i = 0; i < array_length(view_control_transform_start); i++)
	{
		var result = view_transform_scale_project(view_control_transform_start[i], view_control_transform_scale_basis[i], stretch);
		// Absolute snapping applies to the resulting channels, not the drag factor.
		if (setting_snap_absolute)
		{
			var snapval = dragger_snap ? setting_snap_size_scale : snap_min;
			for (var axis = X; axis <= Z; axis++)
				if (abs(result[axis] - view_control_transform_start[i][axis]) > snap_min)
					result[axis] = snap(result[axis], snapval)
		}
		values_x[i] = result[X]
		values_y[i] = result[Y]
		values_z[i] = result[Z]
	}
	return view_transform_space_write(values_x, values_y, values_z)
}
