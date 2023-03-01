/// view_shape_circle(position, radius, [matrix])
/// @arg position
/// @arg radius
/// @arg [matrix]

function view_shape_circle()
{
	var pos, pos2D, rad, rad2D, detail;
	pos = argument[0]
	rad = argument[1]
	
	if (argument_count > 2)
	{
		var mat = array_copy_1d(argument[2]);
		matrix_remove_scale(mat)
		pos = point3D_mul_matrix(pos, mat)
	}
	
	pos2D = view_shape_project(pos)
	if (point3D_project_error)
		return 0
	
	rad2D = ((rad / point3D_distance(pos, cam_from)) * render_height) / (cam_fov / 60)
	detail = 32
	
	for (var i = 0; i < 1; i += 1 / detail)
	{
		view_shape_line_draw(
			point2D(
				pos2D[X] + lengthdir_x(rad2D, (i - 1 / detail) * 360), 
				pos2D[Y] + lengthdir_y(rad2D, (i - 1 / detail) * 360)
			), 
			point2D(
				pos2D[X] + lengthdir_x(rad2D, i * 360), 
				pos2D[Y] + lengthdir_y(rad2D, i * 360)
			)
		)
	}
}
