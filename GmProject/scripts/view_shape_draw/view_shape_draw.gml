/// @desc Renders a shape from 8 points.
/// @arg points
/// @arg [matrix]

function view_shape_draw(points, mat = null)
{
	if (mat != null)
	{
		// Convert to world space
		var matcopy = array_copy_1d(mat);
		matrix_remove_scale(matcopy)
		for (var p = 0; p < 8; p++)
			points[p] = point3D_mul_matrix(points[p], matcopy)
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
