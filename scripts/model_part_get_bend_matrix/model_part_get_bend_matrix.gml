/// model_part_get_bend_matrix(part, bend, position, [scale])
/// @arg part
/// @arg bend
/// @arg position
/// @arg scale
/// @desc Returns the transformation matrix for bending. The scale factor is used to combat Z-fighting.

var part, bend, pos, rot, sca;
part = argument[0]
bend = argument[1]
pos = argument[2]

if (argument_count > 3)
	sca = argument[3]
else
	sca = vec3(1)

if (part.bend_part = null)
	return MAT_IDENTITY
	
// Limit angle
for (var i = X; i <= Z; i++)
{
	if (bend[i] = 0)
		continue
	
	// Clamp to a valid angle
	//bend[i] = tl_value_clamp(e_value.BEND_ANGLE_X + i, bend[i])
	
	// Limit by bend range
	bend[i] = clamp(bend[i], part.bend_direction_min[i], part.bend_direction_max[i])
	
	// Invert
	if (part.bend_invert[i])
		bend[i] *= -1
	
	// Reset if not defined
	if (!part.bend_axis[i])
		bend[i] = 0
}

// Get position
switch (part.bend_part)
{
	case e_part.RIGHT: case e_part.LEFT:
		pos[X] = part.bend_offset
		if (object_index = obj_model_shape)
			pos[X] -= position[X]
		break
		
	case e_part.FRONT: case e_part.BACK:
		pos[Y] = part.bend_offset
		if (object_index = obj_model_shape)
			pos[Y] -= position[Y]
		break
		
	case e_part.UPPER: case e_part.LOWER:
		pos[Z] = part.bend_offset
		if (object_index = obj_model_shape)
			pos[Z] -= position[Z]
		break
}

// Create matrix
var mat = matrix_build(pos[X], pos[Y], pos[Z], bend[X], bend[Y], bend[Z], sca[X], sca[Y], sca[Z]);

if (object_index = obj_model_shape)
	mat = matrix_multiply(matrix_build(-pos[X], -pos[Y], -pos[Z], rotation[X], rotation[Y], rotation[Z], 1, 1, 1), mat)

return mat