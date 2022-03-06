/// matrix_create_rotate_to(from, to, [angle])
/// @arg from
/// @arg to
/// @arg [angle]
/// @desc Returns a rotation matrix based on the relation between two points, with angle for optional orienting

function matrix_create_rotate_to(from, to, angle = 0)
{
	var normal, tangent, bitangent;
	normal = vec3_normalize(point3D_sub(to, from))
	tangent = vec3_tangent(normal, angle)
	bitangent = vec3_cross(normal, tangent)
	
	return [ bitangent[X], bitangent[Y], bitangent[Z], 0,
			    normal[X],    normal[Y],    normal[Z], 0,
			   tangent[X],   tangent[Y],   tangent[Z], 0,
			            0,            0,            0, 1 ]
}