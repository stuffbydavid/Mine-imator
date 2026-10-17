/// @desc Adds a triangle to the current vertex buffer.

function vbuffer_add_triangle(pos1, pos2, pos3, tex1, tex2, tex3, normal1 = null, normal2 = null, normal3 = null, invert = false, matrix = null)
{
	if (!is_array(normal1))
	{
		normal1 = vec3_cross(point3D_sub(pos1, pos2), point3D_sub(pos2, pos3))
		normal2 = normal1
		normal3 = normal1
	}

	if (matrix != null)
	{
		var mat = matrix;
		pos1 = point3D_mul_matrix(pos1, mat)
		pos2 = point3D_mul_matrix(pos2, mat)
		pos3 = point3D_mul_matrix(pos3, mat)
		normal1 = vec3_normalize(vec3_mul_matrix(normal1, mat))

		if (normal2 != null)
			normal2 = vec3_normalize(vec3_mul_matrix(normal2, mat))
		else
			normal2 = normal1

		if (normal3 != null)
			normal3 = vec3_normalize(vec3_mul_matrix(normal3, mat))
		else
			normal3 = normal1
	}

	// Invert
	if (invert)
	{
		var tmp = pos1;
		pos1 = pos2
		pos2 = tmp
		tmp = tex1
		tex1 = tex2
		tex2 = tmp
		normal1 = vec3_mul(normal1, -1)
		normal2 = vec3_mul(normal2, -1)
		normal3 = vec3_mul(normal3, -1)
	}

	normal1 = vec3_normalize(normal1)
	normal2 = vec3_normalize(normal2)
	normal3 = vec3_normalize(normal3)

	vertex_add(pos1, normal1, tex1)
	vertex_add(pos2, normal2, tex2)
	vertex_add(pos3, normal3, tex3)
}
