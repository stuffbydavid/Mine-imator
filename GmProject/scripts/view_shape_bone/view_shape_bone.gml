/// view_shape_bone(pos, length, mat)
/// @arg pos
/// @arg length
/// @arg mat

function view_shape_bone(pos, length, mat)
{
	var bonemat = matrix_multiply(matrix_create(vec3(0), vec3(0), vec3(length)), mat);
	
	var points, points2D, points2Derror, pointlines;
	points = 
	[
		[0, 0, 0],
		
		[.125, .125, 1/6],
		[-.125, .125, 1/6],
		[-.125, -.125, 1/6],
		[.125, -.125, 1/6],
		
		[0, 0, 1]
	]
	
	pointlines = 
	[
		0, 1,
		0, 2,
		0, 3,
		0, 4,
		
		1, 2,
		2, 3,
		3, 4,
		4, 1,
		
		5, 1,
		5, 2,
		5, 3,
		5, 4
	]
	
	for (var i = 0; i < 6; i++)
	{
		points[i] = point3D_add(pos, point3D_mul_matrix(points[i], bonemat))
		points2D[i] = view_shape_project(points[i])
		points2Derror[i] = point3D_project_error
	}
	
	var p1, p2;
	
	render_set_culling(false)
	
	for (var i = 0; i < array_length(pointlines); i += 2)
	{
		p1 = pointlines[i]
		p2 = pointlines[i + 1]
		
		if (!points2Derror[p1] && !points2Derror[p2])
			draw_line_width(points2D[p1][X], points2D[p1][Y], points2D[p2][X], points2D[p2][Y], 2)
	}
	
	render_set_culling(true)
}