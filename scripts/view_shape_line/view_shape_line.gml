/// view_shape_line(point1, point2)
/// @arg point1
/// @arg point2
/// @desc Draws line between 3D points, clips points if off-screen. (Should only use for potentially large lines.)

function view_shape_line(p1, p2)
{
	var p1_2d, p1error, p2_2d, p2error;
	p1_2d = view_shape_project(p1)
	p1error = point3D_project_error
	
	p2_2d = view_shape_project(p2)
	p2error = point3D_project_error
	
	if (p1error && p2error)
		return 0
	
	// Clip off-screen point to camera
	var camdir, dir;
	if (p1error)
	{
		camdir = vec3_direction(cam_from, cam_to)
		dir = vec3_direction(p1, p2)
		p1 = point3D_plane_intersect(point3D_add(cam_from, vec3_mul(camdir, cam_near)), camdir, p2, dir)
		p1_2d = view_shape_project(p1)
		
		if (array_equals(dir, vec3_direction(p1, p2)))
			p1error = false
	}
	else if (p2error)
	{
		camdir = vec3_direction(cam_from, cam_to)
		dir = vec3_direction(p2, p1)
		p2 = point3D_plane_intersect(point3D_add(cam_from, vec3_mul(camdir, cam_near)), camdir, p1, dir)
		p2_2d = view_shape_project(p2)
		
		if (array_equals(dir, vec3_direction(p2, p1)))
			p2error = false
	}
	
	// Still have an error
	if (p1error || p2error)
		return 0
	
	view_shape_line_draw(p1_2d, p2_2d)
}
