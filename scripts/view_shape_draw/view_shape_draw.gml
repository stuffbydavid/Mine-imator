/// view_shape_draw(points, [matrix])
/// @arg points
/// @arg [matrix]
/// @desc Renders a shape from 8 points.

function view_shape_draw()
{
	var points;
	points = argument[0]
	
	if (argument_count > 1)
	{
		// Convert to world space
		var mat = array_copy_1d(argument[1]);
		matrix_remove_scale(mat)
		for (var p = 0; p < 8; p++)
			points[p] = point3D_mul_matrix(points[p], mat)
	}
	
	view_shape_line(points[0], points[1])
	view_shape_line(points[0], points[2])
	view_shape_line(points[0], points[4])
	view_shape_line(points[1], points[3])
	view_shape_line(points[1], points[5])
	view_shape_line(points[2], points[3])
	view_shape_line(points[2], points[6])
	view_shape_line(points[3], points[7])
	view_shape_line(points[4], points[5])
	view_shape_line(points[4], points[6])
	view_shape_line(points[5], points[7])
	view_shape_line(points[6], points[7])
}
