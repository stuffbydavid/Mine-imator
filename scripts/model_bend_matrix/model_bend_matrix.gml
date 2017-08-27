/// model_bend_matrix(part, angle)
/// @arg part
/// @arg angle
/// @desc Returns the transformation matrix for bending.

var part, angle, pos, rot, scale;
part = argument0
angle = argument1

if (part.bend_part = null)
	return MAT_IDENTITY
	
// Limit angle
if (part.bend_direction = e_bend.FORWARD)
	angle = min(0, -angle)
else if (part.bend_direction = e_bend.BACKWARD)
	angle = max(0, angle)
	
// Get position
switch (part.bend_part)
{
	case e_part.RIGHT: case e_part.LEFT:
		pos = point3D(part.bend_offset, 0, 0)
		break
		
	case e_part.FRONT: case e_part.BACK:
		pos = point3D(0, part.bend_offset, 0)
		break
		
	case e_part.UPPER: case e_part.LOWER:
		pos = point3D(0, 0, part.bend_offset)
		break
}

// Get rotation
switch (part.bend_axis)
{
	case X:	rot = vec3(angle, 0, 0);	break
	case Y:	rot = vec3(0, angle, 0);	break
	case Z:	rot = vec3(0, 0, angle);	break
}
	
// Get scale
if (angle != 0)
	scale = vec3(app.setting_bend_scale)
else
	scale = vec3(1)
	
return matrix_create(pos, rot, scale)
