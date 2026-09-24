/// view_transform_scale_apply(factors)
/// @arg factors
/// @desc Applies scale factors to captured transform targets.

function view_transform_scale_apply(factors)
{
	if (vec3_length(vec3_sub(factors, vec3(1))) < snap_min && !view_control_transform_history_started)
		return 0

	// Express the requested stretch in world coordinates, then measure it on
	// each stored scale axis. Keep rotation fixed: our channels cannot store shear.
	var stretch = matrix_multiply(matrix_multiply(matrix_inverse_ext(view_control_transform_basis), matrix_create(vec3(0), vec3(0), factors)), view_control_transform_basis)
	var values_x = []
	var values_y = []
	var values_z = []
	for (var i = 0; i < array_length(view_control_transform_start); i++)
	{
		var result = view_transform_scale_project(view_control_transform_start[i], view_control_transform_scale_basis[i], stretch)
		// Absolute snapping applies to the resulting channels, not the drag factor.
		if (setting_snap_absolute)
		{
			var snapval = dragger_snap ? setting_snap_size_scale : snap_min
			for (var axis = X; axis <= Z; axis++)
				if (abs(result[axis] - view_control_transform_start[i][axis]) > snap_min)
					result[axis] = snap(result[axis], snapval)
		}
		values_x[i] = result[X]
		values_y[i] = result[Y]
		values_z[i] = result[Z]
	}

	return view_transform_write(values_x, values_y, values_z)
}
