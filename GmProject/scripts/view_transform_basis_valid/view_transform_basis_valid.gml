/// view_transform_basis_valid(mat, orthogonal)
/// @arg mat
/// @arg orthogonal
/// @desc Checks whether a transform basis can be used for the requested space.

function view_transform_basis_valid(mat, orthogonal)
{
	var basis_x = vec3(mat[0], mat[1], mat[2])
	var basis_y = vec3(mat[4], mat[5], mat[6])
	var basis_z = vec3(mat[8], mat[9], mat[10])

	if (min(vec3_length(basis_x), vec3_length(basis_y), vec3_length(basis_z)) <= snap_min)
		return false

	basis_x = vec3_normalize(basis_x)
	basis_y = vec3_normalize(basis_y)
	basis_z = vec3_normalize(basis_z)
	if (abs(vec3_dot(vec3_cross(basis_x, basis_y), basis_z)) < 0.00001)
		return false

	return !orthogonal || (abs(vec3_dot(basis_x, basis_y)) < 0.00001 && abs(vec3_dot(basis_x, basis_z)) < 0.00001 && abs(vec3_dot(basis_y, basis_z)) < 0.00001 && vec3_dot(vec3_cross(basis_x, basis_y), basis_z) > 0)
}
