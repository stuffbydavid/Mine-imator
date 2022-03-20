/// view_shape_line(point1, point2)
/// @arg point1
/// @arg point2

function view_shape_line(p1, p2)
{
	var p1_2d, p1error, p2_2d, p2error;
	p1_2d = view_shape_project(p1)
	p1error = point3D_project_error
	
	p2_2d = view_shape_project(p2)
	p2error = point3D_project_error
	
	if (!p1error && !p2error)
		view_shape_line_draw(p1_2d, p2_2d)
}
