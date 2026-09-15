/// view_control_rotate(view)
/// @arg view

function view_control_rotate(view)
{
	var len, xrot, yrot, zrot;
	len = point3D_distance(cam_from, tl_edit.world_pos) * view_3d_control_size * 0.6
	
	var rotation_space = view_rotation_space_effective();

	// Create matrices
	if (rotation_space = e_rotation_space.GLOBAL)
	{
		zrot = matrix_build(tl_edit.world_pos[X], tl_edit.world_pos[Y], tl_edit.world_pos[Z], 0, 0, 0, 1, 1, 1)
	}
	else if (rotation_space = e_rotation_space.LOCAL)
	{
		var local_euler = vec3(tl_edit.value[e_value.ROT_X], tl_edit.value[e_value.ROT_Y], tl_edit.value[e_value.ROT_Z])
		var local_rotation = matrix_build(0, 0, 0, local_euler[X], local_euler[Y], local_euler[Z], 1, 1, 1)
		var parent_rotation = view_rotation_matrix_orthonormal(view_rotation_parent_matrix(tl_edit))
		zrot = view_rotation_matrix_orthonormal(matrix_multiply(local_rotation, parent_rotation))
		zrot[MAT_X] = tl_edit.world_pos[X]
		zrot[MAT_Y] = tl_edit.world_pos[Y]
		zrot[MAT_Z] = tl_edit.world_pos[Z]
	}
	else with (tl_edit)
	{
		zrot = array_copy_1d(matrix_parent)
		zrot[MAT_X] = matrix[MAT_X]
		zrot[MAT_Y] = matrix[MAT_Y]
		zrot[MAT_Z] = matrix[MAT_Z]
		matrix_remove_scale(zrot)
	}

	if (rotation_space = e_rotation_space.GIMBAL)
	{
		xrot = matrix_multiply(matrix_build(0, 0, 0, 0, -90, tl_edit.value[e_value.ROT_Z], 1, 1, 1), zrot)
		yrot = matrix_multiply(matrix_build(0, 0, 0, tl_edit.value[e_value.ROT_X] + 90, 0, tl_edit.value[e_value.ROT_Z], 1, 1, 1), zrot)
	}
	else
	{
		xrot = matrix_multiply(matrix_build(0, 0, 0, 0, -90, 0, 1, 1, 1), zrot)
		yrot = matrix_multiply(matrix_build(0, 0, 0, 90, 0, 0, 1, 1, 1), zrot)
	}

	// Keep Gimbal's established RGB palette. Global uses complementary world
	// colors, while Local uses lighter axis colors so the active basis is also
	// visible directly on the gizmo.
	var color_x = c_control_red;
	var color_y = setting_z_is_up ? c_control_green : c_control_blue;
	var color_z = setting_z_is_up ? c_control_blue : c_control_green;
	if (rotation_space = e_rotation_space.GLOBAL)
	{
		color_x = c_control_cyan
		color_y = setting_z_is_up ? c_control_magenta : c_control_yellow
		color_z = setting_z_is_up ? c_control_yellow : c_control_magenta
	}
	else if (rotation_space = e_rotation_space.LOCAL)
	{
		color_x = merge_color(c_control_red, c_control_white, .45)
		color_y = merge_color(setting_z_is_up ? c_control_green : c_control_blue, c_control_white, .45)
		color_z = merge_color(setting_z_is_up ? c_control_blue : c_control_green, c_control_white, .45)
	}
	
	// Draw each axis
	view_control_rotate_axis(view, e_view_control.ROT_X, e_value.ROT_X, color_x, xrot, len)
	view_control_rotate_axis(view, e_view_control.ROT_Y, e_value.ROT_Y, color_y, yrot, len)
	view_control_rotate_axis(view, e_view_control.ROT_Z, e_value.ROT_Z, color_z, zrot, len)
	
	// Is dragging
	if (window_busy = "rendercontrol" && view_control_edit_view = view && view_control_edit >= e_view_control.ROT_X && view_control_edit <= e_view_control.ROT_Z)
	{
		mouse_cursor = cr_handpoint
		
		if (!mouse_still)
		{
			var ang, prevang, rot, snapval, axesang, newval;
			axis_edit = view_control_edit - e_view_control.ROT_X
			
			// Find rotate amount
			ang = point_direction(mouse_x - content_x, mouse_y - content_y, view_control_pos[X], view_control_pos[Y])
			prevang = point_direction(mouse_previous_x - content_x, mouse_previous_y - content_y, view_control_pos[X], view_control_pos[Y])
			rot = angle_difference_fix(ang, prevang) * negate(view_control_flip)
			view_control_move_distance += rot * dragger_multiplier
			
			snapval = (dragger_snap ? setting_snap_size_rotation : snap_min)
			axesang = view_control_move_distance
			
			if (!setting_snap_absolute && dragger_snap)
				axesang = snap(axesang, snapval)
			
			var rotation_space_angle = axesang;
			if (setting_snap_absolute || !dragger_snap)
				rotation_space_angle = snap(view_control_value + rotation_space_angle, snapval) - view_control_value

			newval = view_control_value + axesang
			newval = tl_value_clamp(e_value.ROT_X + axis_edit, newval)
			
			if (setting_snap_absolute || !dragger_snap)
				newval = snap(newval, snapval)
			
			newval -= tl_edit.value[e_value.ROT_X + axis_edit]
			
			// Update
			if (view_control_rotation_mode = e_rotation_space.GIMBAL)
			{
				tl_value_set_start(action_tl_frame_rot, true)
				tl_value_set(e_value.ROT_X + axis_edit, newval, true)
				tl_value_set_done()
			}
			else
				view_rotation_space_apply(rotation_space_angle)
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
			view_control_rotation_target_ids = []
			ds_map_clear(view_control_rotation_target_map)
			view_control_rotation_history_started = false
		}
	}
}

function action_view_rotation_space(value)
{
	if (window_busy = "rendercontrol")
		return 0

	setting_rotation_space = clamp(round(value), e_rotation_space.GIMBAL, e_rotation_space.amount - 1)
	view_rotation_space_update_selection()
	return 0
}

function action_view_rotation_space_cycle()
{
	action_view_rotation_space((setting_rotation_space + 1) mod e_rotation_space.amount)
}

function view_rotation_space_effective()
{
	if (setting_rotation_space = e_rotation_space.GIMBAL)
		return e_rotation_space.GIMBAL

	view_rotation_space_refresh_constraints()
	return view_control_rotation_constrained ? e_rotation_space.GIMBAL : setting_rotation_space
}

function view_rotation_space_refresh_constraints()
{
	view_control_rotation_constrained = view_control_rotation_selected_keyframe_mixed ||
		(view_control_rotation_selected_keyframe_marker != noone &&
		 view_control_rotation_selected_keyframe_marker != timeline_marker)
	for (var i = 0; i < array_length(view_control_rotation_selection_ids); i++)
	{
		var timeline = view_control_rotation_selection_ids[i];
		if (instance_exists(timeline) &&
			(timeline.lock || timeline.value[e_value.IK_TARGET] != null ||
			 timeline.value[e_value.PATH_OBJ] != null ||
			 !view_rotation_parent_supported(timeline) ||
			 (timeline.part_of != null && timeline.part_of.inherit_pose)))
		{
			view_control_rotation_constrained = true
			break
		}
	}
	return view_control_rotation_constrained
}

function view_rotation_space_update_selection()
{
	view_control_rotation_selection_ids = []
	view_control_rotation_selected_keyframe_marker = noone
	view_control_rotation_selected_keyframe_mixed = false
	with (obj_timeline)
	{
		if (selected && value_type[e_value_type.TRANSFORM_ROT])
			other.view_control_rotation_selection_ids[array_length(other.view_control_rotation_selection_ids)] = id
	}
	with (obj_keyframe)
	{
		if (!selected || !timeline.selected || !timeline.value_type[e_value_type.TRANSFORM_ROT])
			continue
		if (other.view_control_rotation_selected_keyframe_marker = noone)
			other.view_control_rotation_selected_keyframe_marker = position
		else if (other.view_control_rotation_selected_keyframe_marker != position)
			other.view_control_rotation_selected_keyframe_mixed = true
	}

	return view_rotation_space_refresh_constraints()
}

function view_rotation_matrix_orthonormal(matrix)
{
	var x_axis = vec3(matrix[0], matrix[1], matrix[2]);
	var y_axis = vec3(matrix[4], matrix[5], matrix[6]);
	var z_reference = vec3(matrix[8], matrix[9], matrix[10]);

	if (vec3_length(x_axis) <= snap_min || vec3_length(y_axis) <= snap_min)
		return matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1)

	x_axis = vec3_normalize(x_axis)
	y_axis = vec3_sub(y_axis, vec3_mul(x_axis, vec3_dot(y_axis, x_axis)))
	if (vec3_length(y_axis) <= snap_min)
		return matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1)

	y_axis = vec3_normalize(y_axis)
	var z_axis = vec3_normalize(vec3_cross(x_axis, y_axis));
	if (vec3_dot(z_axis, z_reference) < 0)
		z_axis = vec3_mul(z_axis, -1)
	y_axis = vec3_normalize(vec3_cross(z_axis, x_axis))

	return [
		x_axis[X], x_axis[Y], x_axis[Z], 0,
		y_axis[X], y_axis[Y], y_axis[Z], 0,
		z_axis[X], z_axis[Y], z_axis[Z], 0,
		0, 0, 0, 1
	]
}

function view_rotation_parent_matrix(timeline)
{
	if (!timeline.inherit_rotation)
		return MAT_IDENTITY

	// matrix_parent can have its rotation removed by position inheritance.
	// Both evaluated matrices belong to the same update, so the local basis
	// cancels even when value[] already contains the next authored rotation.
	return matrix_multiply(matrix_inverse_ext(timeline.matrix_local), timeline.matrix)
}

function view_rotation_parent_supported(timeline)
{
	if (min(timeline.value[e_value.SCA_X], timeline.value[e_value.SCA_Y], timeline.value[e_value.SCA_Z]) <= snap_min)
		return false
	var scale_tolerance = 0.00001 * max(timeline.value[e_value.SCA_X], timeline.value[e_value.SCA_Y], timeline.value[e_value.SCA_Z]);
	if (abs(timeline.value[e_value.SCA_X] - timeline.value[e_value.SCA_Y]) > scale_tolerance ||
		abs(timeline.value[e_value.SCA_X] - timeline.value[e_value.SCA_Z]) > scale_tolerance)
		return false

	var matrix = view_rotation_parent_matrix(timeline);
	var x_axis = vec3(matrix[0], matrix[1], matrix[2]);
	var y_axis = vec3(matrix[4], matrix[5], matrix[6]);
	var z_axis = vec3(matrix[8], matrix[9], matrix[10]);
	var length_x = vec3_length(x_axis);
	var length_y = vec3_length(y_axis);
	var length_z = vec3_length(z_axis);
	if (min(length_x, length_y, length_z) <= snap_min)
		return false

	// A world rotation under a stretched or mirrored parent can require shear,
	// which cannot be represented by changing the child's Euler channels.
	var tolerance = 0.00001 * max(length_x, length_y, length_z);
	if (abs(length_x - length_y) > tolerance || abs(length_x - length_z) > tolerance)
		return false
	x_axis = vec3_normalize(x_axis)
	y_axis = vec3_normalize(y_axis)
	z_axis = vec3_normalize(z_axis)
	return abs(vec3_dot(x_axis, y_axis)) < 0.00001 &&
		abs(vec3_dot(x_axis, z_axis)) < 0.00001 &&
		abs(vec3_dot(y_axis, z_axis)) < 0.00001 &&
		vec3_dot(vec3_cross(x_axis, y_axis), z_axis) > 0
}

function view_rotation_space_begin(axis_world)
{
	view_rotation_space_update_selection()
	view_control_rotation_mode = view_rotation_space_effective()
	if (view_control_rotation_mode = e_rotation_space.GIMBAL)
		return 0

	view_control_rotation_axis_world = vec3_normalize(axis_world)
	view_control_rotation_target_ids = []
	ds_map_clear(view_control_rotation_target_map)
	view_control_rotation_history_started = false
	view_control_rotation_start_eulers = []
	view_control_rotation_previous_eulers = []
	view_control_rotation_start_world = []
	view_control_rotation_parent = []
	view_control_rotation_parent_selected = []

	with (obj_timeline)
	{
		if (!selected || !value_type[e_value_type.TRANSFORM_ROT])
			continue

		var target_index = array_length(other.view_control_rotation_target_ids);
		var start_euler = vec3(value[e_value.ROT_X], value[e_value.ROT_Y], value[e_value.ROT_Z]);
		var local_rotation = matrix_build(0, 0, 0, start_euler[X], start_euler[Y], start_euler[Z], 1, 1, 1);
		// Reconstruct the authored world basis instead of reading matrix_render.
		// The rendered matrix may still be from the previous viewport update while
		// a newly-authored rotation keyframe is already visible in value[].
		var parent_rotation = view_rotation_matrix_orthonormal(view_rotation_parent_matrix(id));
		var world_rotation = view_rotation_matrix_orthonormal(matrix_multiply(local_rotation, parent_rotation));
		var selected_parent_rotates = false;
		var hierarchy_child = id;
		while (hierarchy_child.parent != app)
		{
			if (!hierarchy_child.inherit_rotation)
				break
			hierarchy_child = hierarchy_child.parent
			if (hierarchy_child.selected && hierarchy_child.value_type[e_value_type.TRANSFORM_ROT])
			{
				selected_parent_rotates = true
				break
			}
		}

		var target_save_id = save_id_get(id);
		other.view_control_rotation_target_ids[target_index] = target_save_id
		ds_map_add(other.view_control_rotation_target_map, target_save_id, target_index)
		other.view_control_rotation_start_eulers[target_index] = start_euler
		other.view_control_rotation_previous_eulers[target_index] = start_euler
		other.view_control_rotation_start_world[target_index] = world_rotation
		other.view_control_rotation_parent[target_index] = parent_rotation
		other.view_control_rotation_parent_selected[target_index] = selected_parent_rotates
	}

	return 0
}

function view_rotation_axis_matrix_degrees(axis, angle)
{
	axis = vec3_normalize(axis)
	var radians = degtorad(angle);
	var cosine = cos(radians);
	var sine = sin(radians);
	var one_minus_cosine = 1 - cosine;
	var xx = axis[X] * axis[X];
	var yy = axis[Y] * axis[Y];
	var zz = axis[Z] * axis[Z];
	var xy = axis[X] * axis[Y] * one_minus_cosine;
	var yz = axis[Y] * axis[Z] * one_minus_cosine;
	var zx = axis[Z] * axis[X] * one_minus_cosine;

	return [
		xx + (1 - xx) * cosine, xy - axis[Z] * sine, zx + axis[Y] * sine, 0,
		xy + axis[Z] * sine, yy + (1 - yy) * cosine, yz - axis[X] * sine, 0,
		zx - axis[Y] * sine, yz + axis[X] * sine, zz + (1 - zz) * cosine, 0,
		0, 0, 0, 1
	]
}

function view_rotation_euler_near(matrix, reference)
{
	var t1 = arctan2(matrix[9], matrix[10]);
	var c2 = sqrt(matrix[0] * matrix[0] + matrix[4] * matrix[4]);
	var t2 = arctan2(-matrix[8], c2);
	var s1 = sin(t1);
	var c1 = cos(t1);
	var t3 = arctan2(s1 * matrix[2] - c1 * matrix[1], c1 * matrix[5] - s1 * matrix[6]);
	var candidate_a = vec3_mul([t2, t1, t3], 180 / pi);
	var rebuilt = matrix_build(0, 0, 0, candidate_a[X], candidate_a[Y], candidate_a[Z], 1, 1, 1);
	t1 = arctan2(rebuilt[9], rebuilt[10])
	c2 = sqrt(rebuilt[0] * rebuilt[0] + rebuilt[4] * rebuilt[4])
	t2 = arctan2(-rebuilt[8], c2)
	s1 = sin(t1)
	c1 = cos(t1)
	t3 = arctan2(s1 * rebuilt[2] - c1 * rebuilt[1], c1 * rebuilt[5] - s1 * rebuilt[6])
	candidate_a = vec3_mul([t2, t1, t3], 180 / pi)

	t1 = arctan2(-matrix[9], -matrix[10])
	c2 = sqrt(matrix[0] * matrix[0] + matrix[4] * matrix[4])
	t2 = arctan2(-matrix[8], -c2)
	s1 = sin(t1)
	c1 = cos(t1)
	t3 = arctan2(s1 * matrix[2] - c1 * matrix[1], c1 * matrix[5] - s1 * matrix[6])
	var candidate_b = vec3_mul([t2, t1, t3], 180 / pi);
	rebuilt = matrix_build(0, 0, 0, candidate_b[X], candidate_b[Y], candidate_b[Z], 1, 1, 1)
	t1 = arctan2(-rebuilt[9], -rebuilt[10])
	c2 = sqrt(rebuilt[0] * rebuilt[0] + rebuilt[4] * rebuilt[4])
	t2 = arctan2(-rebuilt[8], -c2)
	s1 = sin(t1)
	c1 = cos(t1)
	t3 = arctan2(s1 * rebuilt[2] - c1 * rebuilt[1], c1 * rebuilt[5] - s1 * rebuilt[6])
	candidate_b = vec3_mul([t2, t1, t3], 180 / pi)

	var distance_a = 0;
	var distance_b = 0;
	for (var i = 0; i < 3; i++)
	{
		candidate_a[i] = reference[i] + angle_difference_fix(candidate_a[i], reference[i])
		candidate_b[i] = reference[i] + angle_difference_fix(candidate_b[i], reference[i])
		distance_a += power(candidate_a[i] - reference[i], 2)
		distance_b += power(candidate_b[i] - reference[i], 2)
	}

	return distance_b < distance_a ? candidate_b : candidate_a
}

function view_rotation_space_apply(angle)
{
	var target_amount = array_length(view_control_rotation_target_ids);
	if (target_amount = 0)
		return 0

	var delta_world = view_rotation_axis_matrix_degrees(view_control_rotation_axis_world, angle);
	var rotation_target_x = array_create(target_amount);
	var rotation_target_y = array_create(target_amount);
	var rotation_target_z = array_create(target_amount);

	for (var i = 0; i < target_amount; i++)
	{
		var target_world = matrix_multiply(view_control_rotation_start_world[i], delta_world);
		var target_parent = view_control_rotation_parent[i];
		if (view_control_rotation_parent_selected[i])
			target_parent = matrix_multiply(target_parent, delta_world)
		var target_local = matrix_multiply(target_world, matrix_inverse_ext(target_parent));
		var target_euler = view_rotation_euler_near(target_local, view_control_rotation_previous_eulers[i]);
		for (var axis = 0; axis < 3; axis++)
			if (abs(target_euler[axis] - view_control_rotation_start_eulers[i][axis]) < 0.001)
				target_euler[axis] = view_control_rotation_start_eulers[i][axis]
		view_control_rotation_previous_eulers[i] = target_euler
		rotation_target_x[i] = target_euler[X]
		rotation_target_y[i] = target_euler[Y]
		rotation_target_z[i] = target_euler[Z]
	}

	tl_value_set_start_targets(action_tl_frame_rot_xyz, view_control_rotation_history_started, view_control_rotation_target_map)
	view_control_rotation_history_started = true
	tl_value_set_target_values(e_value.ROT_X, view_control_rotation_target_map, rotation_target_x)
	tl_value_set_target_values(e_value.ROT_Y, view_control_rotation_target_map, rotation_target_y)
	tl_value_set_target_values(e_value.ROT_Z, view_control_rotation_target_map, rotation_target_z)
	tl_value_set_done()
	return 0
}
