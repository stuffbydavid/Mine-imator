/// view_transform_scale_project(start_scale, channel_basis, stretch)
/// @arg start_scale
/// @arg channel_basis
/// @arg stretch
/// @desc Projects a world-space stretch onto the stored scale channels.

function view_transform_scale_project(start_scale, channel_basis, stretch)
{
	var result = vec3(1)
	for (var axis = X; axis <= Z; axis++)
	{
		var axis_direction = vec3(channel_basis[axis * 4], channel_basis[axis * 4 + 1], channel_basis[axis * 4 + 2])
		var stretched = vec3_mul_matrix(axis_direction, stretch)
		var factor = vec3_length(stretched) / vec3_length(axis_direction)
		if (vec3_dot(axis_direction, stretched) < 0)
			factor = -factor
		result[axis] = start_scale[axis] * factor
	}

	return result
}
