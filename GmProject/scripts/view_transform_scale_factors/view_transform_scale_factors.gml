/// view_transform_scale_factors(move, axes)
/// @arg move
/// @arg axes
/// @desc Converts a scale drag into per-axis factors.

function view_transform_scale_factors(move, axes)
{
	var factors = vec3(1)
	var snapval = dragger_snap ? setting_snap_size_scale : snap_min
	for (var axis = X; axis <= Z; axis++)
		if (axes[axis])
			factors[axis] = 1 + (setting_snap_absolute ? move[axis] : snap(move[axis], snapval))

	return factors
}
