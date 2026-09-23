/// view_transform_orientation(timeline)
/// @arg timeline
/// @desc Builds the timeline's world orientation basis.

function view_transform_orientation(timeline)
{
	var parent_basis = timeline.inherit_rotation ? view_rotation_matrix_orthonormal(view_transform_parent_matrix(timeline)) : MAT_IDENTITY
	var local_basis = matrix_create(vec3(0), vec3(timeline.value[e_value.ROT_X], timeline.value[e_value.ROT_Y], timeline.value[e_value.ROT_Z]), vec3(1))

	return matrix_multiply(local_basis, parent_basis)
}
