/// model_part_get_bend_matrix(part, angle, position)
/// @arg part
/// @arg angle
/// @arg position
/// @desc Returns the transformation matrix for bending.

var part, angle, pos, rot, scale;
part = argument0
angle = tl_value_clamp(e_value.BEND_ANGLE, argument1)
pos = argument2

if (part.bend_part = null)
	return MAT_IDENTITY
	
// Invert angle
if (part.bend_invert)
	angle = -angle
	
// Limit angle
if (part.bend_direction = e_bend.FORWARD)
	angle = min(0, -angle)
else if (part.bend_direction = e_bend.BACKWARD)
	angle = max(0, angle)
	
// Get position
switch (part.bend_part)
{
	case e_part.RIGHT: case e_part.LEFT:
		pos[X] = part.bend_offset
		break
		
	case e_part.FRONT: case e_part.BACK:
		pos[Y] = part.bend_offset
		break
		
	case e_part.UPPER: case e_part.LOWER:
		pos[Z] = part.bend_offset
		break
}

// Get rotation
switch (part.bend_axis)
{
	case X:	rot = vec3(angle, 0, 0); break
	case Y:	rot = vec3(0, angle, 0); break
	case Z:	rot = vec3(0, 0, angle); break
}
	
// Get scale
if (angle != 0)
	scale = vec3(app.setting_bend_scale)
else
	scale = vec3(1)
	
return matrix_create(pos, rot, scale)
