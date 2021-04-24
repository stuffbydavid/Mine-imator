/// view_shape_project(point)
/// @arg point

function view_shape_project(point)
{
	return point3D_project(point, view_proj_matrix, app.content_width, app.content_height)
}
