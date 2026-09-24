/// view_rotation_axis_matrix_degrees(axis, angle)
/// @arg axis
/// @arg angle

function view_rotation_axis_matrix_degrees(axis, angle)
{
	// Rodrigues' formula converts the dragged world axis and angle to a matrix.
	axis = vec3_normalize(axis)
	var radians = degtorad(angle)
	var cosine = cos(radians)
	var sine = sin(radians)
	var one_minus_cosine = 1 - cosine
	var xx = axis[X] * axis[X]
	var yy = axis[Y] * axis[Y]
	var zz = axis[Z] * axis[Z]
	var xy = axis[X] * axis[Y] * one_minus_cosine
	var yz = axis[Y] * axis[Z] * one_minus_cosine
	var zx = axis[Z] * axis[X] * one_minus_cosine

	return [
		xx + (1 - xx) * cosine, xy - axis[Z] * sine, zx + axis[Y] * sine, 0,
		xy + axis[Z] * sine, yy + (1 - yy) * cosine, yz - axis[X] * sine, 0,
		zx - axis[Y] * sine, yz + axis[X] * sine, zz + (1 - zz) * cosine, 0,
		0, 0, 0, 1
	]
}
