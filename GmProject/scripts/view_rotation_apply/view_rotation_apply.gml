/// view_rotation_apply(angle)
/// @arg angle

function view_rotation_apply(angle)
{
	var target_amount = array_length(view_control_transform_start)
	if (target_amount = 0)
		return 0

	var delta_world = view_rotation_axis_matrix_degrees(view_control_rotation_axis_world, angle)
	var rotation_target_x = array_create(target_amount)
	var rotation_target_y = array_create(target_amount)
	var rotation_target_z = array_create(target_amount)

	for (var i = 0; i < target_amount; i++)
	{
		var target_world = matrix_multiply(view_control_rotation_start_world[i], delta_world)
		var target_parent = view_control_rotation_parent[i]

		// A selected ancestor receives this delta too. Remove its updated basis
		// before converting back to local angles to avoid rotating the child twice.
		if (view_control_rotation_parent_selected[i])
			target_parent = matrix_multiply(target_parent, delta_world)

		var target_local = matrix_multiply(target_world, matrix_inverse_ext(target_parent))
		var target_euler = view_rotation_euler_near(target_local, view_control_rotation_previous_eulers[i])
		for (var axis = 0; axis < 3; axis++)
		{
			if (abs(target_euler[axis] - view_control_transform_start[i][axis]) < 0.001)
				target_euler[axis] = view_control_transform_start[i][axis]
		}

		view_control_rotation_previous_eulers[i] = target_euler
		rotation_target_x[i] = target_euler[X]
		rotation_target_y[i] = target_euler[Y]
		rotation_target_z[i] = target_euler[Z]
	}

	return view_transform_write(rotation_target_x, rotation_target_y, rotation_target_z)
}
