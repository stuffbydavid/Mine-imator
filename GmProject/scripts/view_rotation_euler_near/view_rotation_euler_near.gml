/// view_rotation_euler_near(matrix, reference)
/// @arg matrix
/// @arg reference

function view_rotation_euler_near(matrix, reference)
{
	// The same orientation has two Euler branches. Choose the one nearest the
	// current animation values, especially when crossing a 90-degree rotation.
	var t1 = arctan2(matrix[9], matrix[10])
	var c2 = sqrt(matrix[0] * matrix[0] + matrix[4] * matrix[4])
	var t2 = arctan2(-matrix[8], c2)
	var s1 = sin(t1)
	var c1 = cos(t1)
	var t3 = arctan2(s1 * matrix[2] - c1 * matrix[1], c1 * matrix[5] - s1 * matrix[6])
	var candidate_a = vec3_mul([t2, t1, t3], 180 / pi)
	var rebuilt = matrix_build(0, 0, 0, candidate_a[X], candidate_a[Y], candidate_a[Z], 1, 1, 1)

	t1 = arctan2(rebuilt[9], rebuilt[10])
	c2 = sqrt(rebuilt[0] * rebuilt[0] + rebuilt[4] * rebuilt[4])
	t2 = arctan2(-rebuilt[8], c2)
	s1 = sin(t1)
	c1 = cos(t1)
	t3 = arctan2(s1 * rebuilt[2] - c1 * rebuilt[1], c1 * rebuilt[5] - s1 * rebuilt[6])
	candidate_a = vec3_mul([t2, t1, t3], 180 / pi)

	t1 = arctan2(-matrix[9], -matrix[10])
	c2 = sqrt(matrix[0] * matrix[0] + matrix[4] * matrix[4])
	t2 = arctan2(-matrix[8], -c2)
	s1 = sin(t1)
	c1 = cos(t1)
	t3 = arctan2(s1 * matrix[2] - c1 * matrix[1], c1 * matrix[5] - s1 * matrix[6])
	var candidate_b = vec3_mul([t2, t1, t3], 180 / pi)
	rebuilt = matrix_build(0, 0, 0, candidate_b[X], candidate_b[Y], candidate_b[Z], 1, 1, 1)

	t1 = arctan2(-rebuilt[9], -rebuilt[10])
	c2 = sqrt(rebuilt[0] * rebuilt[0] + rebuilt[4] * rebuilt[4])
	t2 = arctan2(-rebuilt[8], -c2)
	s1 = sin(t1)
	c1 = cos(t1)
	t3 = arctan2(s1 * rebuilt[2] - c1 * rebuilt[1], c1 * rebuilt[5] - s1 * rebuilt[6])
	candidate_b = vec3_mul([t2, t1, t3], 180 / pi)

	var distance_a = 0
	var distance_b = 0
	// Unwrap both branches around the previous update so full turns survive.
	for (var i = 0; i < 3; i++)
	{
		candidate_a[i] = reference[i] + angle_difference_fix(candidate_a[i], reference[i])
		candidate_b[i] = reference[i] + angle_difference_fix(candidate_b[i], reference[i])
		distance_a += power(candidate_a[i] - reference[i], 2)
		distance_b += power(candidate_b[i] - reference[i], 2)
	}

	return distance_b < distance_a ? candidate_b : candidate_a
}
