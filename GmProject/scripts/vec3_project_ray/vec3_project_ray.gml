/// vec3_project_ray(point)
/// @arg point

function vec3_project_ray(point)
{
	// Update view ray
	var px, py, rayclip, rayeye, raywor;
	
	// Get -1 -> 1 XY coordinates in viewport
	px = -(point[X] * 2 - 1)
	py = point[Y] * 2 - 1
	
	rayclip = vec4(px, py, -1, 1);
	rayeye = point4D_mul_matrix(rayclip, matrix_inverse(proj_matrix))
	rayeye = vec4(rayeye[X], rayeye[Y], -1, 0)
	
	raywor = point4D_mul_matrix(rayeye, matrix_inverse(view_matrix))
	return vec3_normalize(vec3(raywor[X], raywor[Y], raywor[Z]))
}