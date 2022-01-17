/// view_control_plane_start(pos, normal)
/// @arg pos
/// @arg normal

function view_control_plane_start(pos, normal)
{
	view_control_plane_normal = vec3_normalize(normal)
	view_control_plane_origin = pos
	
	view_control_plane_offset = point2D_sub(view_shape_project(pos), point2D(mouse_x - content_x, mouse_y - content_y))
	view_control_plane_mouse = point2D(mouse_x, mouse_y)
	
	// Update view ray
	var px, py, rayclip, rayeye, raywor;
	
	// Get -1 -> 1 XY mouse coordinates in viewport
	px = -(((mouse_x - content_x + view_control_plane_offset[X]) / content_width) * 2 - 1)
	py = ((mouse_y - content_y + view_control_plane_offset[Y]) / content_height) * 2 - 1
	
	rayclip = point4D(px, py, -1, 1);
	rayeye = point4D_mul_matrix(rayclip, matrix_inverse(proj_matrix));
	rayeye = point4D(rayeye[X], rayeye[Y], -1, 0)
	
	raywor = point4D_mul_matrix(rayeye, matrix_inverse(view_matrix));
	view_control_ray_dir = vec3_normalize(vec3(raywor[X], raywor[Y], raywor[Z]))
}
