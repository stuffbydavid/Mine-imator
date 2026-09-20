/// view_rotation_parent_supported(timeline)
/// @arg timeline

function view_rotation_parent_supported(timeline)
{
	if (min(timeline.value[e_value.SCA_X], timeline.value[e_value.SCA_Y], timeline.value[e_value.SCA_Z]) <= snap_min)
		return false

	var scale_tolerance = 0.00001 * max(
		timeline.value[e_value.SCA_X],
		timeline.value[e_value.SCA_Y],
		timeline.value[e_value.SCA_Z]
	)
	if (abs(timeline.value[e_value.SCA_X] - timeline.value[e_value.SCA_Y]) > scale_tolerance ||
		abs(timeline.value[e_value.SCA_X] - timeline.value[e_value.SCA_Z]) > scale_tolerance)
		return false

	var parent_matrix = view_rotation_parent_matrix(timeline)
	var axis_x = vec3(parent_matrix[0], parent_matrix[1], parent_matrix[2])
	var axis_y = vec3(parent_matrix[4], parent_matrix[5], parent_matrix[6])
	var axis_z = vec3(parent_matrix[8], parent_matrix[9], parent_matrix[10])
	var length_x = vec3_length(axis_x)
	var length_y = vec3_length(axis_y)
	var length_z = vec3_length(axis_z)
	if (min(length_x, length_y, length_z) <= snap_min)
		return false

	// A stretched or mirrored parent can require shear when rotating in world space.
	var tolerance = 0.00001 * max(length_x, length_y, length_z)
	if (abs(length_x - length_y) > tolerance || abs(length_x - length_z) > tolerance)
		return false

	axis_x = vec3_normalize(axis_x)
	axis_y = vec3_normalize(axis_y)
	axis_z = vec3_normalize(axis_z)
	return abs(vec3_dot(axis_x, axis_y)) < 0.00001 &&
		abs(vec3_dot(axis_x, axis_z)) < 0.00001 &&
		abs(vec3_dot(axis_y, axis_z)) < 0.00001 &&
		vec3_dot(vec3_cross(axis_x, axis_y), axis_z) > 0
}
