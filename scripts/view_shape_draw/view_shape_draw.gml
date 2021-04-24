/// view_shape_draw(points, [matrix])
/// @arg points
/// @arg [matrix]
/// @desc Renders a shape from 8 points.

function view_shape_draw()
{
	var points, points2D, pointserror;
	points = argument[0]
	
	if (argument_count > 1)
	{
		// Convert to world space
		var mat = array_copy_1d(argument[1]);
		matrix_remove_scale(mat)
		for (var p = 0; p < 8; p++)
			points[p] = point3D_mul_matrix(points[p], mat)
	}
	
	// Convert to screen space
	for (var p = 0; p < 8; p++)
	{
		points2D[p] = view_shape_project(points[p])
		pointserror[p] = point3D_project_error
	}
	
	if (!pointserror[0] && !pointserror[1])
		view_shape_line_draw(points2D[0], points2D[1])
	
	if (!pointserror[0] && !pointserror[2])
		view_shape_line_draw(points2D[0], points2D[2])
	
	if (!pointserror[0] && !pointserror[4])
		view_shape_line_draw(points2D[0], points2D[4])
	
	if (!pointserror[1] && !pointserror[3])
		view_shape_line_draw(points2D[1], points2D[3])
	
	if (!pointserror[1] && !pointserror[5])
		view_shape_line_draw(points2D[1], points2D[5])
	
	if (!pointserror[2] && !pointserror[3])
		view_shape_line_draw(points2D[2], points2D[3])
	
	if (!pointserror[2] && !pointserror[6])
		view_shape_line_draw(points2D[2], points2D[6])
	
	if (!pointserror[3] && !pointserror[7])
		view_shape_line_draw(points2D[3], points2D[7])
	
	if (!pointserror[4] && !pointserror[5])
		view_shape_line_draw(points2D[4], points2D[5])
	
	if (!pointserror[4] && !pointserror[6])
		view_shape_line_draw(points2D[4], points2D[6])
	
	if (!pointserror[5] && !pointserror[7])
		view_shape_line_draw(points2D[5], points2D[7])
	
	if (!pointserror[6] && !pointserror[7])
		view_shape_line_draw(points2D[6], points2D[7])
}
