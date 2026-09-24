/// view_transform_move_apply(move, axes)
/// @arg move
/// @arg axes
/// @desc Applies a movement delta to captured transform targets.

function view_transform_move_apply(move, axes)
{
	var snapval = dragger_snap ? setting_snap_size_position : snap_min
	for (var axis = X; axis <= Z; axis++)
	{
		if (!axes[axis])
			move[axis] = 0
		else if (setting_snap_absolute)
			move[axis] = snap(view_control_transform_origin[axis] + move[axis], snapval) - view_control_transform_origin[axis]
		else
			move[axis] = snap(move[axis], snapval)
	}

	var world_delta = vec3_mul_matrix(move, view_control_transform_basis)
	if (vec3_length(world_delta) < snap_min && !view_control_transform_history_started)
		return 0

	var values_x = []
	var values_y = []
	var values_z = []
	for (var i = 0; i < array_length(view_control_transform_start); i++)
	{
		// Each selected root has its own parent coordinates. Inverting that
		// basis gives every root the same world displacement, even when scaled.
		var delta = vec3_mul_matrix(world_delta, view_control_transform_parent_inverse[i])
		var result = vec3_add(view_control_transform_start[i], delta)
		values_x[i] = result[X]
		values_y[i] = result[Y]
		values_z[i] = result[Z]
	}

	return view_transform_write(values_x, values_y, values_z)
}
