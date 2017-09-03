/// vbuffer_add_triangle(x1, y1, z1, x2, y2, z2, x3, y3, z3, tx1, ty1, tx2, ty2, tx3, ty3)
/// vbuffer_add_triangle(pos1, pos2, pos3, texcoord1, texcoord2, texcoord3, [normal, [color, [matrix]]])
/// @arg pos1
/// @arg pos2
/// @arg pos3
/// @arg texcoord1
/// @arg texcoord2
/// @arg texcoord3
/// @arg [normal
/// @arg [color
/// @arg [matrix]]]

if (argument_count < 15)
{
	var pos1, pos2, pos3, tex1, tex2, tex3, normal, color;
	pos1 = argument[0]
	pos2 = argument[1]
	pos3 = argument[2]
	tex1 = argument[3]
	tex2 = argument[4]
	tex3 = argument[5]
	
	if (argument_count > 6 && is_array(argument[6]))
		normal = argument[6]
	else
		normal = vec3_cross(point3D_sub(pos1, pos2), point3D_sub(pos2, pos3))
	
	if (argument_count > 7 && argument[7] != null)
		color = argument[7]
	else
		color = -1
	
	if (argument_count > 8)
	{
		var mat = argument[8];
		pos1 = point3D_mul_matrix(pos1, mat)
		pos2 = point3D_mul_matrix(pos2, mat)
		pos3 = point3D_mul_matrix(pos3, mat)
		normal = vec3_normalize(vec3_mul_matrix(normal, mat))
	}
	
	vertex_add(pos1, normal, tex1, color)
	vertex_add(pos2, normal, tex2, color)
	vertex_add(pos3, normal, tex3, color)
}
else
{
	var x1, y1, z1, x2, y2, z2, x3, y3, z3;
	var nx, ny, nz;

	x1 = argument[0]
	y1 = argument[1]
	z1 = argument[2]
	x2 = argument[3]
	y2 = argument[4]
	z2 = argument[5]
	x3 = argument[6]
	y3 = argument[7]
	z3 = argument[8]

	nx = (z1 - z2) * (y3 - y2) - (y1 - y2) * (z3 - z2)
	ny = (x1 - x2) * (z3 - z2) - (z1 - z2) * (x3 - x2)
	nz = (y1 - y2) * (x3 - x2) - (x1 - x2) * (y3 - y2)

	vertex_add(x1, y1, z1, nx, ny, nz, argument[9], argument[10])
	vertex_add(x2, y2, z2, nx, ny, nz, argument[11], argument[12])
	vertex_add(x3, y3, z3, nx, ny, nz, argument[13], argument[14])
}
