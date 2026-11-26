/// @arg position
/// @arg radius
/// @arg [matrix]

function view_shape_circle(pos, rad, mat = null)
{
	var pos2d, rad2d, detail;
	
	if (mat != null)
	{
		var matcopy = array_copy_1d(mat);
		matrix_remove_scale(matcopy)
		pos = point3D_mul_matrix(pos, matcopy)
	}
	
	pos2d = view_shape_project(pos)
	if (point3D_project_error)
		return 0
	
	// Use perpendicular distance to get correct scale at edges of screen
	var camdir, cdist;
	camdir = vec3_direction(cam_from, cam_to)
	cdist = abs(
				(camdir[X] * (pos[X] - cam_from[X])) +
				(camdir[Y] * (pos[Y] - cam_from[Y])) +
				(camdir[Z] * (pos[Z] - cam_from[Z]))
			) / sqrt(
				power(camdir[X], 2) +
				power(camdir[Y], 2) +
				power(camdir[Z], 2)
			)
	rad2d = ((rad / cdist) * render_height) / (cam_fov / 58.72) //point3D_distance(pos, cam_from)
	
	detail = 32
	
	for (var i = 0; i < 1; i += 1 / detail)
	{
		view_shape_line_draw(
			point2D(
				pos2d[X] + lengthdir_x(rad2d, (i - 1 / detail) * 360), 
				pos2d[Y] + lengthdir_y(rad2d, (i - 1 / detail) * 360)
			), 
			point2D(
				pos2d[X] + lengthdir_x(rad2d, i * 360), 
				pos2d[Y] + lengthdir_y(rad2d, i * 360)
			)
		)
	}
}
