/// view_rotation_matrix_orthonormal(matrix)
/// @arg matrix

function view_rotation_matrix_orthonormal(matrix)
{
	var axis_x = vec3(matrix[0], matrix[1], matrix[2])
	var axis_y = vec3(matrix[4], matrix[5], matrix[6])
	var axis_z_reference = vec3(matrix[8], matrix[9], matrix[10])

	if (vec3_length(axis_x) <= snap_min || vec3_length(axis_y) <= snap_min)
		return matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1)

	axis_x = vec3_normalize(axis_x)

	// Remove scale and make the gizmo axes perpendicular.
	axis_y = vec3_sub(axis_y, vec3_mul(axis_x, vec3_dot(axis_y, axis_x)))
	if (vec3_length(axis_y) <= snap_min)
		return matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1)

	axis_y = vec3_normalize(axis_y)
	var axis_z = vec3_normalize(vec3_cross(axis_x, axis_y))
	if (vec3_dot(axis_z, axis_z_reference) < 0)
		axis_z = vec3_mul(axis_z, -1)
	axis_y = vec3_normalize(vec3_cross(axis_z, axis_x))

	return [
		axis_x[X], axis_x[Y], axis_x[Z], 0,
		axis_y[X], axis_y[Y], axis_y[Z], 0,
		axis_z[X], axis_z[Y], axis_z[Z], 0,
		0, 0, 0, 1
	]
}
