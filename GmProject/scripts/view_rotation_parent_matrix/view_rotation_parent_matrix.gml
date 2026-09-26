/// view_rotation_parent_matrix(timeline)
/// @arg timeline

function view_rotation_parent_matrix(timeline)
{
	if (!timeline.inherit_rotation)
		return MAT_IDENTITY

	// matrix_parent can lose rotation when position inheritance is disabled.
	// These two matrices are from the same update, so the local basis cancels.
	return matrix_multiply(matrix_inverse_ext(timeline.matrix_local), timeline.matrix)
}
