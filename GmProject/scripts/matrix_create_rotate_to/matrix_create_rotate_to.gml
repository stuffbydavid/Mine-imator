/// matrix_create_rotate_to(tangent, normal)
/// @arg tangent
/// @arg normal
/// @desc Returns a TBN coordinate frame for rotation

function matrix_create_rotate_to(tangent, normal)
{
	var binormal = vec3_normalize(vec3_cross(tangent, normal));
	
	return [ binormal[X], binormal[Y], binormal[Z], 0,
			  tangent[X],  tangent[Y],  tangent[Z], 0,
			   normal[X],   normal[Y],   normal[Z], 0,
					   0,           0,           0, 1 ]
}