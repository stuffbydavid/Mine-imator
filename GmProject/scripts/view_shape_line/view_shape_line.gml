/// @desc Draws line between 3D points, clips points if off-screen. (Should only use for potentially large lines.)
/// @arg point1
/// @arg point2

function view_shape_line(p1, p2)
{
	var p1proj, p1error, p2proj, p2error;
	p1proj = view_shape_project(p1)
	p1error = point3D_project_error
	
	p2proj = view_shape_project(p2)
	p2error = point3D_project_error
	
	if (p1error && p2error)
		return 0
	
	// Clip off-screen point to camera
	var camdir, dir;
	if (p1error)
	{
		camdir = vec3_direction(cam_from, cam_to)
		dir = vec3_direction(p1, p2)
		p1 = ray_plane_intersect(p2, dir, point3D_add(cam_from, vec3_mul(camdir, cam_near)), camdir)
		p1proj = view_shape_project(p1)
		
		if (array_equals(dir, vec3_direction(p1, p2)))
			p1error = false
	}
	else if (p2error)
	{
		camdir = vec3_direction(cam_from, cam_to)
		dir = vec3_direction(p2, p1)
		p2 = ray_plane_intersect(p2, dir, point3D_add(cam_from, vec3_mul(camdir, cam_near)), camdir)
		p2proj = view_shape_project(p2)
		
		if (array_equals(dir, vec3_direction(p2, p1)))
			p2error = false
	}
	
	// Still have an error
	if (p1error && p2error)
		return 0
	
	view_shape_line_draw(p1proj, p2proj)
}
