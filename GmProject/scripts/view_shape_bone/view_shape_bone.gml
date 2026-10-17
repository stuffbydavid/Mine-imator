/// @arg position
/// @arg length
/// @arg matrix

function view_shape_bone(pos, length, mat)
{
	var bonemat, points, pointlines, points2d, points2derror;
	bonemat = matrix_multiply(matrix_create(vec3(0), vec3(0), vec3(length)), mat)
	points = [
		[ 0, 0, 0 ],
		
		[ .125, .125, 1/6 ],
		[ -.125, .125, 1/6 ],
		[ -.125, -.125, 1/6 ],
		[ .125, -.125, 1/6 ],
		
		[ 0, 0, 1 ]
	]
	pointlines = [
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
		points2d[i] = view_shape_project(points[i])
		points2derror[i] = point3D_project_error
	}
	
	render_set_culling(false)
	
	for (var i = 0; i < array_length(pointlines); i += 2)
	{
		var p1, p2;
		p1 = pointlines[i]
		p2 = pointlines[i + 1]
		
		if (!points2derror[p1] && !points2derror[p2])
			draw_line_width(points2d[p1][X], points2d[p1][Y], points2d[p2][X], points2d[p2][Y], 2)
	}
	
	render_set_culling(true)
}
